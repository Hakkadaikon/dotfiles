---
paths:
  - "**/*"
---

# ループエンジニアリング(NL → EARS → TLA+ → Gherkin)

自然言語の要求を、3 重フィードバックループで段階的に厳密化する。各ループは検証器を検証対象より上位層に置く。生成物は手編集せずソースから再生成する。

## 発動

正しさを設計段階で固めたい局面 → `loop-engineering` skill 発動。

発動条件:
- ユーザーが「ループエンジニアリング」「EARS」「TLA+」「Gherkin」「設計を検証」「状態機械を検査」「要求を形式化」と言う
- 並行・状態遷移・プロトコルの設計を、コードを書く前にモデル検査で固めたいと判断したとき
- 仕様(RFC、標準、仕様書)を要件へ落とすとき、抽出の網羅性とトレーサビリティを担保したいとき(0段の抽出ループ)

非対象: 状態遷移も並行性も無い単純なロジック(通常テストで足りる)。実装そのものの数学的証明が要るなら formal-verification(Lean)へ。形式化が目的化しないこと(YAGNI)。

詳細規範: skills/loop-engineering/SKILL.md

## 抽出 + 3 ループ

0. **抽出ループ(仕様 → 要件の網羅)**: EARS を書く前に、元仕様(RFC、標準、自然言語仕様)から要件を漏れなく抜く。3ループは「与えられた要件」を厳密に検証するが、抽出の網羅は守らない。漏れは入口に落ちる。
   - **入口**: 仕様を全件走査し要件候補を出し切る。走査アンカーは文書型で変える(規範語=RFC 2119 はその一例、ほかに日本語規範表現「〜しなければならない」、OpenAPI/protobuf の全要素列挙、ストーリーの受け入れ条件など)。過剰抽出は安全、漏れは危険。
   - **工程**: 仕様条項ID → 要件 → 形式手法(TLA+/Lean) → テストのトレーサビリティ表を作り、**空欄=抽出漏れ**として可視化。CI ゲート化は OpenFastTrace / Doorstop。
   - **出口**: ファジング、差分テスト、性質テストで実挙動から漏れを逆検出(既製の適合性スイートはあるドメインだけ。WebSocket=Autobahn 等。無いのが普通)。
   - 死角の典型: TLA+ がバイトを抽象化して捨てた領域、Lean で証明したが実装で未呼出の述語、片系列にだけ入った非対称要件。
1. **外ループ(要求形式化)**: 自然言語(0段で抽出した要件) → EARS 記法 + 状態/ドメインモデル → TLA+ spec。
   - EARS: ubiquitous(SHALL)/ event(WHEN)/ state(WHILE)/ unwanted(IF-THEN)/ optional(WHERE)。各節を `Next` の 1 disjunct に対応させる。
   - `loop-outer SPEC=Name` でテンプレから `Name.tla` と `Name.feature` を scaffold。
2. **中ループ(設計検証)**: TLC で spec を model-check し、`tla_mutate_oracle.py` で spec 自体を mutation testing する。survivor(spec が捕まえられないバグ)が出たら invariant が弱い。
   - `loop-middle SPEC=Name`。
3. **内ループ(受け入れ仕様化)**: TLC の反例トレースを `trace_to_gherkin.py` で Gherkin に変換。設計レベルのバグが失敗する受け入れテストになる。
   - `loop-inner SPEC=Name`。

ツール実体は flake の `tlaplus`(TLC/SANY)と `apalache`。env は `conf.d/loopeng.fish`(`TLA_JAR`/`APALACHE_BIN`/`LOOPENG_HOME`)。Doorstop による要件トレーサビリティが要るときだけ `uv pip install doorstop`。

## Lean 4 形式検証との使い分け(疎結合)

この TLA+ ループと既存の formal-verification(Lean 4)は**並立**。役割で選ぶ:

- **設計の検証 → TLA+**: 状態遷移・並行性・プロトコルの安全性/活性。有限状態空間を網羅探索したいとき。
- **実装の数学的証明 → Lean 4**(`formal-verification` skill / `prover` agent): アルゴリズムの正しさを型と証明で担保したいとき。証明済み性質はそのまま test-first の述語になる。

両者を無理に結線しない(YAGNI)。TLA+ で設計を固め、critical な実装片を Lean で証明し、どちらの成果も Gherkin / テストへ落とす、という分担で足りる。
