---
paths:
  - "**/*"
---

# 形式検証(FV)発動

正しさを数学的に保証したい局面 → formal-verification スキル発動。Lean 4 で雑仕様→形式仕様→証明→test-first を回す。

発動条件:
- ユーザーが「形式検証」「formal verification」「FV」「証明したい」「不変条件を保証」「Lean で書いて」「仕様を形式化」と言う
- アルゴリズム・プロトコル・セキュリティ性質の正しさを通常テストでなく証明で担保したいと判断したとき

動作: precondition/invariant/postcondition へ構造化 → Lean の def+theorem に形式化 → `lake build` で proof repair ループ → 証明済み性質を test-first 実装へ橋渡し。

性質を洗い出すときの原則は **過剰抽出は安全、漏れは危険**。挙げ過ぎた性質は後で「優先度低」「対象外」に落とせるが、挙げ損ねた性質は形式化も証明もされず通常テストをすり抜ける。迷ったらカタログに載せる。

非対象: 通常のユニットテストで足りる検証・証明が過剰な小タスク(YAGNI)。形式化自体が目的化しないこと。`sorry` 入りを「保証済み」と偽らない。

詳細規範: skills/formal-verification/SKILL.md
