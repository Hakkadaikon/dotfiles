---
paths:
  - "**/*"
---

# ループエンジニアリング(NL → EARS → TLA+ → Gherkin)

自然言語の要求を、3 重フィードバックループで段階的に厳密化する。各ループは検証器を検証対象より上位層に置く。生成物は手編集せずソースから再生成する。

## 3 ループ

1. **外ループ(要求形式化)**: 自然言語 → EARS 記法 + 状態/ドメインモデル → TLA+ spec。
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
