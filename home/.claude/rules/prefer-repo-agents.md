# agent の委任先

委任するかを先に決める。数回のツール呼び出しで済む作業と、結果をすぐ自分で使う確認は委任せず自分でやる。委任の条件と並列に配るときの運用(ゲートの二段化・並列は3本まで・事故の予防)は hymme の `skills/_shared/parallel-delegation.md` に従う。

実装・設計(plan)・レビューを agent に委任する前に、作業中リポジトリの `.claude/agents/` を確認する。同種の agent があれば、その指示・ツール制約・出力形式を優先してリポ側に委任する。

リポ側に無いときの委任先:

- 実装: `hymme:coder`
- 過剰設計レビュー: `ponytail:ponytail-review` スキル(多観点は `hymme:diff-review` スキル)
- TLA+ / Lean: `hymme:modeler` / `hymme:prover`(完了前の検査は `hymme:verification-reviewer`)
- 調査: 組み込みの `Explore`
