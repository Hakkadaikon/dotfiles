---
paths:
  - "**/*"
---

# micro-commit 常時適用

git 管理下のコード/ドキュメントを編集 → コミット段階で micro-commit スキル発動。

発動条件:
- 編集ファイルが git 管理下(`git ls-files` 該当 or 追跡対象の新規ファイル)
- 変更を確定する局面(「コミットして」「commit」、または作業完了で未コミット差分あり)

動作: 変更を ~30-50 行の論理単位に分割し conventional commit で連続コミット。

非対象: git 管理外ファイル・一時ファイル・ユーザーが単一コミット明示時。

詳細規範: skills/micro-commit/SKILL.md
