---
name: loop-engineering
description: >
  自然言語の要求を EARS 記法 + 状態/ドメインモデルへ構造化し、TLA+ で設計を網羅検査し、
  TLC の反例を Gherkin の受け入れ仕様に落とすまでの 3 重フィードバックループ。
  ユーザーが「ループエンジニアリング」「EARS」「TLA+」「Gherkin」「設計を検証」「状態機械を検査」
  「要求を形式化」と言ったとき、または並行・状態遷移・プロトコル設計の正しさを実装前に
  モデル検査で固めたいときに使用する。設計は TLA+、実装の数学的証明は formal-verification(Lean)。
---

# Loop Engineering (NL → EARS → TLA+ → Gherkin)

自然言語の要求を 3 つのフィードバックループで段階的に厳密化する。各ループは検証器を検証対象より上位層に置く。生成物(spec / feature)は手編集せずソースから再生成する。LLM が要求を構造化し、TLC が網羅探索で厳密に検査するハイブリッド。

設計の正しさは **TLA+**(このループ)、実装そのものの数学的証明は **formal-verification(Lean 4)**。役割が違う。無理に結線しない(YAGNI)。

## 前提ツール

flake の `tools` に含む(`./env.sh install` 済みなら入っている)。

- `tlc` / `sany` … TLA+ のモデル検査器とパーサ(JDK 同梱ラッパー)。
- `apalache-mc` … 型チェック + 記号モデル検査(無限状態を扱いたいとき)。
- `loop-outer` / `loop-middle` / `loop-inner` … `Makefile.loopeng` 経由のループ駆動(fish 関数)。
- env: `LOOPENG_HOME` / `TLA_JAR` / `APALACHE_BIN`(`conf.d/loopeng.fish`)。

未導入なら導入を促し、勝手に大規模インストールしない。

## ワークフロー

順に進む。各ループで止まって検証する。`SPEC=<Name>` を通して呼ぶ。

### 1. 外ループ — NL を EARS + 状態/ドメインモデルへ

雑な NL 要求を、まず2つに構造化する。曖昧な点はモデル化前にユーザーへ確認する。

- **EARS 記法**で各要求を1文ずつ書く。型を取り違えない:
  - ubiquitous: 「The <system> SHALL <response>.」(常時成り立つ義務)
  - event: 「WHEN <trigger> the <system> SHALL <response>.」(イベント駆動)
  - state: 「WHILE <state> the <system> SHALL <response>.」(状態継続中)
  - unwanted: 「IF <condition> THEN the <system> SHALL <response>.」(異常系)
  - optional: 「WHERE <feature> the <system> SHALL <response>.」(条件付き機能)
- **状態/ドメインモデル**: 名詞=状態変数、各変数の型(取りうる値域)、初期状態、不変条件を洗い出す。EARS の各節がどの状態遷移に対応するかを対応づける。

`loop-outer SPEC=<Name>` でテンプレから `<Name>.tla` と `<Name>.feature` を scaffold する(既存ファイルは壊さない)。scaffold した spec を EARS とモデルから埋める:

- `VARIABLES` = ドメインモデルの状態変数。
- `TypeOK` = 各変数の型(値域)を `\in` で書く。網羅性のアンカー。
- `Init` = 初期状態。
- `Next` = **EARS の各 event/state/unwanted 節を 1 disjunct** に。`\/ Action1 \/ Action2 ...`。1節1アクションを崩さない。
- `Inv` = EARS の ubiquitous / 「SHALL never」を安全性として書く。temporal(応答義務・到達性)が要るなら `<>`/`[]` で別途性質を立てる。

`<Name>.cfg` に `INIT` / `NEXT` / `INVARIANT`(必要なら状態空間を絞る `CONSTANT`)を書く。

### 2. 中ループ — TLA+ で設計を検査し、検査の強さ自体を検証する

`loop-middle SPEC=<Name>` を回す。2段ある:

1. **model-check**: TLC が `Inv` を全到達状態で検査する。`No error` なら設計は不変条件を守る。反例が出たら設計の穴 → 内ループへ。
2. **mutation oracle**(自作メタ検証 `tla_mutate_oracle.py`): spec に機械的ミューテーション(`<`→`\leq`、`=`→`#`、`/\`→`\/`、`+`→`-`)を注入し、それぞれ TLC が検出(killed)するか確認する。

**survivor が出たら spec が弱い。** ミューテーションを TLC が捕まえられない = 不変条件や `Next` がそのバグを区別できない。survivor を1つずつ見て、不変条件を締めるか、検査範囲(`cfg` の状態空間)を広げる。「kills every mutant」になるまで回す。これが「検証器を検証する」上位ループ。

- 状態空間が有限化できない/大きいときは Apalache(`apalache-mc check`)で型チェック+記号検査。
- 発散するミューテーント(無限状態)は `MUT_TIMEOUT=<秒>` で打ち切る(timeout=killed 扱い)。

### 3. 内ループ — TLC の反例を Gherkin の受け入れ仕様へ

`Inv` を破る反例が出たら、それは設計レベルのバグであると同時に**実行可能な反例**。`loop-inner SPEC=<Name>` で TLC のエラートレースを `<Name>.feature` の Gherkin Scenario に変換する(`trace_to_gherkin.py`)。

- 初期状態 = `Given`、各アクション = `When`、変化した変数 = `Then becomes ...`。
- この feature は「この振る舞いは起きてはならない」失敗例。設計を直して反例が消えるまで外/中ループへ戻す。
- 設計が固まったら、正の受け入れシナリオ(EARS の正常系)を `.feature` に足し、実装の受け入れテストにする。

## 3 ループの回し方

外(要求形式化)→ 中(設計検査 + 検査の強さ検証)→ 内(反例の受け入れ仕様化)→ 直して外へ、を反例と survivor が尽きるまで回す。3 つは独立した検証層で、下の層の出力が上の層の入力になる。

## formal-verification(Lean)との橋渡し

設計が固まった後、**critical な実装片**(アルゴリズム・セキュリティ性質)は Lean で数学的に証明する → `formal-verification` skill / `prover` agent。TLA+ で「設計が正しい」、Lean で「実装が設計通り」を分担する。どちらの成果も Gherkin / property test に落とす。両者を機械的に変換しようとしない(YAGNI)。

## やらないこと

- 生成物(`.tla` / `.feature`)を手編集して源泉(EARS + モデル)と乖離させない。源泉を直して再生成する。
- survivor を残したまま「設計検証済み」と言わない。mutation oracle が緑になって初めて検査が信用できる。
- 通常のユニットテストで足りる小タスクにループを持ち込まない。状態遷移・並行・プロトコルが無いなら過剰。
- 小さく始める。1 spec の Counter 例が3ループ通ってから本題へ広げる。
