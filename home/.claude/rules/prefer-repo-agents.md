# agent の委任先

実装・設計(plan)・レビューを agent に委任する前に、作業中リポジトリの `.claude/agents/` を確認する。同種の agent があれば、その指示・ツール制約・出力形式を優先してリポ側に委任する。

リポ側に無いときの委任先:

- 実装: `hymme:coder`
- 過剰設計レビュー: `hymme:code-reviewer`(多観点は `hymme:diff-review` スキル)
- TLA+ / Lean: `hymme:modeler` / `hymme:prover`
- 調査: `explorer`
- 日本語の散文: `jp-writer`
