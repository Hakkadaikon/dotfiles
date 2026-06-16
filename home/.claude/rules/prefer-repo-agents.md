# リポジトリ側 agents 優先

コーディング・plan・レビューを agent に委任する前に、作業中リポジトリの `.claude/agents/` を確認する。同種の agent がリポ側にあれば、ユーザーグローバル(`~/.claude/agents/`)の同種 agent より**リポ側を優先**して使う。

- 同名 agent: Claude Code が project スコープを自動優先するため、そのまま委任すればリポ側が使われる
- 別名だが同種(例: リポ側 `reviewer` と user 側 `code-reviewer`): リポ側に書かれた指示を優先し、リポ側 agent に委任する
- リポ側に該当 agent が無いときだけ、user グローバルの coder / jp-writer / explorer / code-reviewer を使う

判定対象は実装・設計(plan)・レビューの3系統。リポ側の agent 定義に書かれた規範・ツール制約・出力形式を、グローバル側より優先する。
