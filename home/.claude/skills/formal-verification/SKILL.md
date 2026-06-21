---
name: formal-verification
description: >
  雑な仕様を Lean 4 の形式仕様へ落とし込み、証明で検証し、そこから test-first で実装へ繋ぐワークフロー。
  ユーザーが「形式検証」「formal verification」「FV」「証明したい」「不変条件を保証」「Lean で書いて」
  「仕様を形式化」と言ったとき、またはアルゴリズム・プロトコル・セキュリティ性質の正しさを
  数学的に保証したいときに使用する。autoformalization と proof repair のループを回す。
---

# Formal Verification (Lean 4)

雑な要件を形式仕様にし、証明支援系で網羅的に検証し、test-first 実装へ繋ぐ。LLM が戦略を立て、Lean が厳密に検証するハイブリッド。証明が通った性質だけが「保証された」と言える。

## 前提ツール

`elan`(flake の tools に含む)が入っていること。なければ `nix profile add .#tools`。

- `elan` … Lean toolchain manager。`lake` / `lean` を供給する。
- 初回のみ `elan default stable` で Lean 4 本体を入れる(これをやるまで `lake` は "no default toolchain" で落ちる)。
- 新規プロジェクト: `lake new <name> math`(Mathlib 付き)or `lake new <name>`(素)。
- ビルド/証明チェック: `lake build`。エラーが証明の穴。

未導入なら導入を促し、勝手に大規模インストールしない。

## ワークフロー

順に進む。各段で止まって検証する。

### 1. 仕様を網羅形式へ

雑な NL 要件 → 構造化(precondition / invariant / postcondition / 想定する脅威)。曖昧な点は実装前にユーザーに確認する。「全ケース」を意識する: 空入力、境界、重複、順序。

### 2. Lean に形式化(autoformalization)

NL → Lean の `def` + `theorem`。例:

```lean
-- 「ソートは要素を保存し、順序付ける」
theorem sort_perm (l : List Int) : (sort l).Perm l := by sorry
theorem sort_sorted (l : List Int) : (sort l).Sorted (· ≤ ·) := by sorry
```

`sorry` で穴を明示してから埋める。型エラー・証明失敗のメッセージを次の段にフィードバックする。

### 3. 証明(proof repair ループ)

- `lake build` で現在の証明状態とエラーを観察。
- tactic を提案 → 実行 → 結果を見る。失敗したら lemma 追加 or 戦略変更。
- 自動化を使う: `simp` / `omega` / `decide` / `exact?` / `apply?`。Mathlib があれば `exact?` で既存補題を探す。
- 1 証明が重いなら補題に分解する。
- **埋まらない `sorry` は残さず明示する**。「ここは未証明」と報告する。嘘の `sorry` を通った証明と偽らない。

### 4. test-first 実装へ橋渡し

形式仕様が「何をテストすべきか」を決める。証明済み性質 → そのまま property-based test の述語にする。

- Lean 内で完結するなら `#eval` / `decide` でチェック、または code extraction。
- 別言語(Rust/TS 等)で実装するなら、各 theorem を1つの property test に対応させ、それを満たす実装を test-first で書く。
- 出力: 証明済み性質の一覧 + 対応するテスト + 実装ガイド + 「形式的に保証された部分」の明示。

## 現実的な期待

- 完全自動は難しい。LLM が戦略、`simp`/`omega`/`exact?` で細部、複雑な所は人間レビュー。
- スケールしないときは critical な性質だけ形式検証する。残りは通常テスト。
- 証明探索はトークン/時間を食う。重い探索は補題に分けて並列に投げる。

## やらないこと

- 通った証明だけを「保証」と呼ぶ。`sorry` 入りを保証扱いしない。
- 形式化が目的化しない。実装が要らない検証はやらない(YAGNI)。
- 小さく始める。1ツール・1仕様の例が回ってから広げる。
