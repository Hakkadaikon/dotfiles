---
name: test-design
description: >
  テストを設計する／既存テストをレビューするための手法カタログと選定ワークフロー。
  対象(機能、モジュール、API、PR 差分)から「テストすべき振る舞い」を網羅抽出し、
  各振る舞いに適切なテスト手法を割り当て、必要な reference だけを読みに行く。
  ユーザーが「テスト設計」「テストケースを洗い出す」「テスト観点」「テストレビュー」
  「どんなテストを書くべき」「カバレッジ」「テスト戦略」「単体テストの考え方」と言ったとき、
  または実装前にテスト項目を固めたい／既存テストの抜けや脆さを点検したいときに使用する。
  実装の駆動は coder agent の TDD、設計の網羅検査は loop-engineering(TLA+)、実装の証明は formal-verification(Lean)。
---

# Test Design (テスト設計とレビュー支援)

テスト手法を網羅したカタログと、対象から適切な手法を選ぶワークフロー。
**SKILL.md は索引**。全手法の定義、目的、TypeScript example は `reference/` に厳密に置き、
**何を作る/レビューするかに応じて必要な reference だけを読みに行く**(全部は読まない)。

役割分担(無理に結線しない、YAGNI):
- **テスト項目の抽出と手法選定**：このスキル
- **実装の駆動(TDD: Red→Green→Refactor)**：`coder` agent
- **設計の網羅検査(状態遷移、並行、プロトコル)**：`loop-engineering`(TLA+)
- **実装の数学的証明(critical なアルゴリズムや性質)**：`formal-verification`(Lean 4)

## 使うとき / 使わないとき

| 使う | 使わない |
| --- | --- |
| 機能/モジュール/API のテスト項目を実装前に洗い出す | 自明な1行や設定値のテスト(YAGNI) |
| PR 差分や既存テストの抜け、脆さをレビューする | 手法が自明で迷いがない小変更 |
| どのテスト手法(同値分割/PBT/E2E…)が適切か選ぶ | (なし) |
| カバレッジやテストの強さ(mutation)を点検する | (なし) |

## ワークフロー

### 1. 対象を見て、テストすべき振る舞いを抽出する(0段)

**いきなりテストを書かない。** 対象から「テストすべき振る舞い」を網羅的に出し切る工程を先に置く。
ここは姉妹スキル `loop-engineering` の「0. 抽出ループ」を踏襲する。漏れはこの入口に落ちる。

原則は **過剰抽出は安全、漏れは危険**。迷ったら採り、後で優先度で落とす。

1. **曖昧な用語と暗黙の要求を先に定義する**：抽出の前に、対象に出てくる語の意味を一つずつ確定させる。「翌営業日」なら「営業日とは? 休日とは(日曜、指定土曜、祝日)? 月跨ぎは?」まで割る。語の定義が曖昧なまま振る舞いを出すと、境界(連休、月末)と異常系がそっくり抜ける。**用語の未定義は最大の抽出漏れ源**。併せて「当たり前要求」(セキュリティ、実行効率、法令)など暗黙のニーズも、非機能の種別として明示に引き上げる。
2. **走査アンカーを選ぶ**：対象の構造単位を決める。受け入れ条件、関数シグネチャ、コードの分岐、状態遷移、API エンドポイント×メソッド、不変条件のいずれかを使う。仕様視点(ブラックボックス)とコード視点(ホワイトボックス)で**独立に**出して union を取ると漏れにくい。
3. **採番チェックリスト台帳に落とす**：[`assets/test-extract-template.md`](assets/test-extract-template.md) を作業領域(`tasks/` 配下など git 管理外)にコピーし、振る舞いごとに `T-001` から連番で1行立てる。頭の中で済ませない。
4. **各振る舞いに種別を振る**：正常系、境界、異常系(unwanted)、非機能のいずれかを振る。各正常系に「不正入力なら? 境界なら? 並行なら?」を必ず問い、異常系の行を系統的に生やす。
5. **全 ID が `[x]` で欠番なしになったら抽出を閉じる**。未チェックが残る=抽出途中。

> レビュー用途のときは、既存テストを台帳の右側(テスト名)に先に埋める。
> **左側(振る舞い)に空欄が残れば、それがテストの抜け**である。
> **手法が実装詳細に密結合していれば、それが脆さ**である。

### 2. 各振る舞いに手法を割り当て、その reference だけ読む

抽出した各 `T-ID` に、どのテスト手法で検証するかを割り当てる。
**割り当てた手法が載っている reference だけを読む**(索引は下表)。
迷ったら、まず種別(正常系、境界、異常系、非機能)から下表で当たりをつける。

| 何を検証したいか | 読む reference |
| --- | --- |
| 粒度の選択(unit/integration/E2E/contract…)、ピラミッド配分 | [`reference/levels.md`](reference/levels.md) |
| テストの配分(ピラミッド/トロフィー)と関心事による階層化 | [`reference/test-strategy.md`](reference/test-strategy.md) |
| 仕様から機械的に導く(同値分割、境界値、デシジョンテーブル、状態遷移、ペアワイズ) | [`reference/blackbox-systematic.md`](reference/blackbox-systematic.md) |
| 経験や業務フローから導く(ユースケース、シナリオ、エラー推測、探索的、アドホック) | [`reference/blackbox-experience.md`](reference/blackbox-experience.md) |
| 構造網羅やカバレッジ、テストの強さ(C0/C1、MC/DC、データフロー、mutation) | [`reference/whitebox-coverage.md`](reference/whitebox-coverage.md) |
| TDD の手順とテスト構成(Red→Green→Refactor、三角測量、AAA、Given-When-Then) | [`reference/tdd-workflow.md`](reference/tdd-workflow.md) |
| 良い単体テストの規範(4本柱、学派、実装詳細を避ける、モックの使いどころ) | [`reference/good-test-principles.md`](reference/good-test-principles.md) |
| テストダブルの使い分け(ダミー/スタブ/モック/スパイ/フェイク、Testcontainers) | [`reference/test-doubles.md`](reference/test-doubles.md) |
| 期待値が用意しにくい(PBT、fuzzing、差分、メタモルフィック、形式検証連携) | [`reference/modern-generative.md`](reference/modern-generative.md) |
| 出力が非決定的(LLM/生成モデルを組み込んだシステム、揺らぎを層で封じ込める) | [`reference/ai-nondeterministic.md`](reference/ai-nondeterministic.md) |
| AI/LLM にテストを書かせる(信頼は限定的、観点出しの叩き台) | [`reference/ai-nondeterministic.md`](reference/ai-nondeterministic.md) |
| 非機能(性能、負荷、a11y、セキュリティ…)や運用(BDD、カナリア、CI ゲート)、静的、並行 | [`reference/nonfunctional-process.md`](reference/nonfunctional-process.md) |

各 reference は手法ごとに **概要 / 目的といつ使うか / TypeScript example / 落とし穴** を厳密に定義している。
example をそのまま雛形にして対象へ写す。

### 3. 実装/検証へ橋渡しする

割り当てが済んだら、台帳のトレーサビリティマトリクス(振る舞い→手法→テスト名)を満たすよう実装側へ渡す。

- **実装の駆動**：テスト項目リストを `coder` agent に渡し、t-wada スタイルの TDD(Red→Green→Refactor)で1項目ずつ消化する。台帳の `T-ID` リストがそのままテストリストになる。
- **設計に状態遷移、並行、順序があるとき**：テストで全 interleaving は踏めない。`loop-engineering`(TLA+)で設計をモデル検査し、反例を Gherkin の受け入れシナリオに落としてから、その述語をテストへ移す。
- **critical なアルゴリズムやセキュリティ性質**：通常テストより強い保証が要るなら `formal-verification`(Lean 4)で証明し、証明済み述語を property-based test(`modern-generative.md`)の property として叩く。

## やらないこと

- **0段(振る舞い抽出)を飛ばしてテストを書かない。** 思いつきで書くと正常系に偏り、境界と異常系が抜ける。
- **reference を全部読まない。** 割り当てた手法のファイルだけ開く(progressive disclosure)。
- **カバレッジ率を目的化しない。** 高 C0/C1 は「到達」を示すだけで「検証」を保証しない。テストの強さは mutation(`whitebox-coverage.md`)で点検する。
- **モックを濫用しない。** 実装詳細に結合したテストは脆い。詳細は `good-test-principles.md`。
- 自明な1行や設定値にテストを先行させない(YAGNI)。
