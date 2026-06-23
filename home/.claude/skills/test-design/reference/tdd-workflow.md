# TDD の手順とテスト構成

テスト駆動開発で実装を駆動する手順と、テスト本体の構成パターンをまとめる。
出典は t-wada(和田卓人)の TDD 観点。
「良いテストとは何か」の規範は [`good-test-principles.md`](good-test-principles.md)、テストダブルの使い分けは [`test-doubles.md`](test-doubles.md) を参照。

各項目は「概要」「目的/いつ使う」「TypeScript example(vitest 想定)」「落とし穴」の構成で示す。

## 目次

- [TDD(Red→Green→Refactor)](#tddredgreenrefactor)
- [テストリスト先行](#テストリスト先行)
- [三角測量(Triangulation)](#三角測量triangulation)
- [仮実装と明白な実装(Fake it / Obvious implementation)](#仮実装と明白な実装fake-it--obvious-implementation)
- [AAA パターン(Arrange-Act-Assert)](#aaa-パターンarrange-act-assert)
- [Given-When-Then(BDD 由来)](#given-when-thenbdd-由来)

---

## TDD(Red→Green→Refactor)

### 概要
失敗するテストを先に書き(**Red**)、それを通す最小のコードを書き(**Green**)、テストを保ったまま設計を整える(**Refactor**)、という三拍子を小さく回す開発手法。

### 目的/いつ使う
実装を外側の振る舞いから駆動し、テスト不能な設計に流れるのを防ぐ。
非自明なロジック(分岐、ループ、パーサー、金額やセキュリティの経路)で使う。
設定値や自明な一行に持ち込むのは過剰で、YAGNI に反する。

各フェーズの規律は次のとおり。

- **Red**：テストを一本だけ書き、実際に実行して落ちることを確認する。落ちる理由が期待どおりかも見る。これはテスト自身のバグを検出する工程でもある。
- **Green**：そのテストを通す最小限のコードを書く。ベタ書きでよい。まず緑にすることを優先する。
- **Refactor**：緑を保ったまま重複を除き、設計を整える。テストが通り続けることを各ステップで確認する。

### TypeScript example
```ts
import { describe, it, expect } from "vitest";

// Red: まだ存在しない関数を呼ぶテストを書き、実行して落ちることを確認する
import { fizzbuzz } from "./fizzbuzz";

describe("fizzbuzz", () => {
  it("returns 'Fizz' for multiples of 3", () => {
    expect(fizzbuzz(3)).toBe("Fizz");
  });
});

// Green: 最小実装。この時点ではベタ書きでよい
// export const fizzbuzz = (n: number): string => (n % 3 === 0 ? "Fizz" : String(n));
```

### 落とし穴
- Red を飛ばして実装から書くと、テストが常に緑のまま壊れていても気付けない。落ちることの確認を省かない。
- Green で先回りして一般化すると、テストに支えられていないコードが生まれる。最小実装にとどめる。

---

## テストリスト先行

### 概要
着手前に、実装すべき振る舞いを箇条書きのテストリストへ洗い出す。
t-wada 流 TDD の起点であり、正常系、境界、異常系を網羅的に並べる。

### 目的/いつ使う
何を確かめるべきかを先に決め、行き当たりばったりの実装を防ぐ。
リストは一つずつ消化し、作業中に思いついた項目は随時追記する。
全項目を最初に完璧へ揃える必要はなく、見えているものから書き出して走り出す。

### TypeScript example
リストはコードではなく、計画として書く。
```text
# uint パーサー parseUint のテストリスト
- [ ] "0" -> 0
- [ ] "42" -> 42
- [ ] 先頭ゼロ "007" -> 7      (正規化の境界)
- [ ] "" -> エラー            (異常系: 空)
- [ ] "-1" -> エラー          (異常系: 符号)
- [ ] "1.5" -> エラー         (異常系: 非整数)
- [ ] 巨大値の上限           (境界: オーバーフロー)
```

### 落とし穴
- 正常系だけを並べ、異常系と境界を書き落とす。網羅の漏れがそのまま品質の漏れになる。
- リストを清書して固定文書にしようとする。リストは作業用のメモであり、消化と追記で動き続けてよい。

---

## 三角測量(Triangulation)

### 概要
一般化の方針が見えないとき、二つ目、三つ目の具体例(テスト)を足して、仮実装を本実装へ追い込む技法。

### 目的/いつ使う
最初のテストをハードコードで通したあと、一般解への道筋が自明でないときに使う。
方針が自明なら、わざわざ例を増やさず「明白な実装」で一気に書いてよい。
三角測量はあくまで方針が見えないときの補助輪である。

### TypeScript example
```ts
import { describe, it, expect } from "vitest";
import { add } from "./add";

describe("add: triangulation", () => {
  // 1本目だけなら `return 3` でも通る(仮実装)
  it("1 + 2 = 3", () => expect(add(1, 2)).toBe(3));
  // 2本目を足すと、定数では通らず一般化を強制される
  it("3 + 4 = 7", () => expect(add(3, 4)).toBe(7));
});
```

### 落とし穴
- 方針が自明な箇所でも機械的に二本目を足し、冗長なテストを量産する。
- 二本目が一本目と同じ同値クラスにあり、一般化を強制できていない。異なる代表値を選ぶ。

---

## 仮実装と明白な実装(Fake it / Obvious implementation)

### 概要
Green に至る二つの戦略。
**仮実装**は定数を返すなどベタ書きでまず緑にする。
**明白な実装**は正解が自明なときに本実装を直接書く。

### 目的/いつ使う
不安が大きい、または一般化の形が見えないときは仮実装から入り、三角測量で一般化する。
正解に確信があり書き間違える恐れが小さいときは、明白な実装で一気に書く。
二つは対立せず、確信度に応じて選ぶ。

### TypeScript example
```ts
// 仮実装: まず定数で緑にし、後で一般化する
export const square = (n: number): number => 4; // square(2) のテストだけなら通る

// 明白な実装: 正解が自明なので直接書く
export const squareObvious = (n: number): number => n * n;
```

### 落とし穴
- 確信もないのに明白な実装へ飛び、緑だが間違ったコードを書く。不安なら仮実装に戻る。
- 仮実装のまま三角測量を忘れ、定数返しが残る。一般化まで進めて初めて完了する。

---

## AAA パターン(Arrange-Act-Assert)

### 概要
テスト本体を、準備(**Arrange**)、実行(**Act**)、検証(**Assert**)の三段に分ける構成。

### 目的/いつ使う
ほぼすべての単体テストで使える基本構成。
各段を空行で区切ると、何を準備し、何を実行し、何を確かめたかが一目で追える。
Act が複数行に膨らむのは、テスト対象の API が使いにくい兆候である。

### TypeScript example
```ts
import { describe, it, expect } from "vitest";
import { Cart } from "./cart";

describe("Cart", () => {
  it("sums line totals", () => {
    // Arrange
    const cart = new Cart();
    cart.add({ price: 100, qty: 2 });

    // Act
    const total = cart.total();

    // Assert
    expect(total).toBe(200);
  });
});
```

### 落とし穴
- Assert が複数の無関係な事柄を一度に検証し、一テスト一振る舞いの原則を崩す。
- Arrange が肥大して、何の準備が結果に効くのか読み取れなくなる。準備の核だけを残す。

---

## Given-When-Then(BDD 由来)

### 概要
AAA と同型の構成を、振る舞い駆動開発(BDD)の語彙で表す。
前提(**Given**)、操作(**When**)、結果(**Then**)の三段からなる。

### 目的/いつ使う
非技術者にも読める言葉で仕様を記述したいときに使う。
受け入れテストや、Gherkin 形式のシナリオと相性がよい。
構造は AAA と同じであり、語彙が業務寄りになる点だけが違う。

### TypeScript example
```ts
import { describe, it, expect } from "vitest";
import { applyDiscount } from "./discount";

describe("discount for members", () => {
  it("gives 10% off to members", () => {
    // Given a member and a 1000 yen item
    const member = { isMember: true };

    // When the discount is applied
    const price = applyDiscount(1000, member);

    // Then the price is reduced by 10%
    expect(price).toBe(900);
  });
});
```

### 落とし穴
- Given に業務上意味のない技術的詳細を詰め込み、シナリオとしての読みやすさを失う。
- When に操作を二つ以上入れ、どちらが結果を生んだか曖昧にする。
