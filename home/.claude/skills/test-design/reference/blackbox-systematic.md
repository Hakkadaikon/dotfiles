# ブラックボックス設計技法（体系的、仕様ベース）

内部実装を見ず、入出力仕様だけからテストケースを機械的に導く体系的技法群。
ISO/IEC/IEEE 29119-4 はこれらを「仕様ベースのテスト設計技法(specification-based techniques)」として体系化している。
コードを開かずに何を確かめるべきかを決められるので、実装前(TDD のテストリスト)にも有効。

経験と直感に依る非形式的な技法(ユースケース、シナリオ、エラー推測、探索的、アドホック)は [`blackbox-experience.md`](blackbox-experience.md) を参照。

各手法は独立ではなく重ねて使う。
まず同値分割で入力空間を割り、境界値で割れ目を攻め、条件の組合せはデシジョンテーブル、振る舞いの履歴依存は状態遷移、という順で必要なものだけ足す。

## 目次

- [同値分割(Equivalence Partitioning)](#同値分割equivalence-partitioning)
- [境界値分析(Boundary Value Analysis)](#境界値分析boundary-value-analysis)
- [デシジョンテーブル(Decision Table)](#デシジョンテーブルdecision-table)
- [状態遷移テスト(State Transition)](#状態遷移テストstate-transition)
- [原因結果グラフ(Cause-Effect Graph)](#原因結果グラフcause-effect-graph)
- [ペアワイズ/直交表(Pairwise / All-pairs)](#ペアワイズ直交表pairwise--all-pairs)
- [クラシフィケーションツリー法(Classification Tree Method)](#クラシフィケーションツリー法classification-tree-method)

---

## 同値分割(Equivalence Partitioning)

### 概要
入力(または出力)の定義域を、同じように扱われるはずの部分集合(同値クラス)に分割し、各クラスから代表値を1つだけ選ぶ。

### 目的/いつ使う
入力空間が広く全数テストが不可能なとき、代表値で網羅率を保ちつつケース数を圧縮する。
有効クラスと無効クラスの両方を出すのが要点。
クラス内の値が本当に等価かが疑わしい場合(分岐が値ごとに違う等)は使わず、境界値やデシジョンテーブルへ。

### TypeScript example
年齢区分関数 `classifyAge` の同値クラス(子供 0-12 / 大人 13-64 / 高齢 65+ / 無効 <0)を代表値で回す。

```ts
import { describe, it, expect } from "vitest";
import { classifyAge } from "./age";

describe("classifyAge: equivalence partitions", () => {
  const cases = [
    { partition: "child", value: 5, expected: "child" },
    { partition: "adult", value: 30, expected: "adult" },
    { partition: "senior", value: 70, expected: "senior" },
    { partition: "invalid", value: -1, expected: "invalid" },
  ] as const;

  it.each(cases)("$partition ($value) -> $expected", ({ value, expected }) => {
    expect(classifyAge(value)).toBe(expected);
  });
});
```

### 落とし穴
- 無効クラス(範囲外、型違い、空)を出し忘れ、正常系だけになる。
- 「等価」と思った値が実装上は別経路で、1代表では漏れる。区分の根拠は仕様であって願望ではない。

### 網羅の定義

- **網羅基準**：全有効同値クラスから各1代表、かつ全無効同値クラスから各1代表を踏んだとき網羅完了。
- **網羅手順**：
  1. 入力(と出力)の定義域を、同じ扱いを受けるはずの部分集合へ分割する。
  2. 各クラスを有効(仕様が受理)と無効(範囲外、型違い、空)に仕分ける。
  3. 各クラスから代表値を1つ選び、1ケースにする。
- **達成チェック**：代表が割り当たっていないクラスが0であることを確認する。
- 無効クラス(下限未満、上限超、null、空、型不正)を出し忘れて正常系だけになっていないか見る。

---

## 境界値分析(Boundary Value Analysis)

### 概要
同値クラスの境界に欠陥が集中するという経験則に基づき、各境界の直前、境界上、直後の値を狙う。

### 目的/いつ使う
`<` と `<=` の取り違え、オフバイワン、上限下限の扱いを検出する。
同値分割とほぼ常にセットで使う。
順序を持たない離散的入力(列挙値の集合など)には境界が無いので不要。

### TypeScript example
0-100 のみ受理する `isValidScore` を、境界の代表値配列で回す。2点境界(on/off)に加え必要なら3点(直前も)を足す。

```ts
import { describe, it, expect } from "vitest";
import { isValidScore } from "./score";

describe("isValidScore: boundary values (range 0..100)", () => {
  const cases = [
    { value: -1, expected: false }, // 下限直前
    { value: 0, expected: true }, //   下限上
    { value: 1, expected: true }, //   下限直後
    { value: 99, expected: true }, //  上限直前
    { value: 100, expected: true }, // 上限上
    { value: 101, expected: false }, // 上限直後
  ] as const;

  it.each(cases)("score=$value -> $expected", ({ value, expected }) => {
    expect(isValidScore(value)).toBe(expected);
  });
});
```

### 落とし穴
- 浮動小数の境界は次の表現可能値が `±1` でない。`Number.EPSILON` 相当を意識する。
- 上限のみ、下限のみ検査して片側に偏る。両端を必ず出す。

### 網羅の定義

- **網羅基準**：全境界について直前、境界上、直後を踏んだとき網羅完了。2点境界なら on/off の両端で足りる。
- **網羅手順**：
  1. 同値分割で得たクラス間の境界をすべて列挙する。
  2. 各境界に直前、境界上、直後の3点(または on/off の2点)を割り当て、1ケースずつにする。
- **達成チェック**：片側(上限だけ、下限だけ)になっている境界が無いか、両端の対称性を確認する。
- 浮動小数の境界では `±1` でなく次の表現可能値(`Number.EPSILON` 相当)を使えているか見る。

---

## デシジョンテーブル(Decision Table)

### 概要
複数の条件(原因)の真偽の組合せと、それぞれに対応するアクション(結果)を表に並べ、各列(ルール)を1テストケースにする。

### 目的/いつ使う
ビジネスルールが複数条件の AND/OR 組合せで分岐するとき(割引適用、与信判定、料金計算など)。
条件が1つだけ、または独立で組合せ効果が無いときは過剰。

### TypeScript example
会員 × クーポンで送料を決める `shippingFee` のルールを、テーブルの各行として列挙する。

```ts
import { describe, it, expect } from "vitest";
import { shippingFee } from "./shipping";

describe("shippingFee: decision table", () => {
  // member | coupon | expected
  const rules = [
    { member: true, coupon: true, expected: 0 },
    { member: true, coupon: false, expected: 0 },
    { member: false, coupon: true, expected: 0 },
    { member: false, coupon: false, expected: 500 },
  ] as const;

  it.each(rules)(
    "member=$member coupon=$coupon -> fee=$expected",
    ({ member, coupon, expected }) => {
      expect(shippingFee({ member, coupon })).toBe(expected);
    },
  );
});
```

### 落とし穴
- 条件 n 個で組合せは 2ⁿ。意味のない組合せは「実現不可(don't care)」として畳み、全爆発を持ち込まない。
- 表に出ない組合せ(暗黙のデフォルト)を放置すると、そこに欠陥が隠れる。

### 網羅の定義

- **網羅基準**：実現可能な全ルール(条件の組合せ列)を各1ケース踏んだとき網羅完了。
- **網羅手順**：
  1. 分岐に効く条件をすべて抽出する。
  2. 条件 n 個の 2ⁿ 列を表に展開する。
  3. 結果が同一になる実現不可、無意味な列を don't care として畳む。
  4. 残った各列を1ケースにする。
- **達成チェック**：暗黙のデフォルト列が表に明示されているか確認する。
- 畳んだ列が本当に到達不能か(条件間の依存で消えるのか)を再確認する。

---

## 状態遷移テスト(State Transition)

### 概要
対象を状態と遷移(イベント → 次状態)のモデルとして捉え、各遷移、無効遷移、状態の往復をテストする。

### 目的/いつ使う
振る舞いが過去の履歴に依存するとき(注文ステータス、認証セッション、UI のモード)。
正当な遷移だけでなく「その状態で来てはいけないイベント」も検査するのが肝。
入力から出力が一意に決まる純関数には状態が無いので不要。
状態空間が広く全 interleaving や到達性を厳密に押さえたい設計は、テストでなく `loop-engineering`(TLA+)でモデル検査してから、反例をここへ落とす。

### TypeScript example
注文ステートマシン `next(state, event)` の遷移表をそのままテーブルにする。無効遷移は現状維持(または例外)を確認。

```ts
import { describe, it, expect } from "vitest";
import { next } from "./order";

describe("order state machine: transitions", () => {
  const valid = [
    { from: "created", event: "pay", to: "paid" },
    { from: "paid", event: "ship", to: "shipped" },
    { from: "shipped", event: "deliver", to: "delivered" },
  ] as const;

  it.each(valid)("$from --$event--> $to", ({ from, event, to }) => {
    expect(next(from, event)).toBe(to);
  });

  it("rejects invalid transition (created --ship-->)", () => {
    expect(() => next("created", "ship")).toThrow();
  });
});
```

### 落とし穴
- 有効遷移だけ書いて、無効イベント(状態 × 起こり得ないイベント)を全く検査しない。欠陥はそこに住む。
- 状態爆発。0-switch(各遷移1回)で足り、必要な箇所だけ N-switch(連鎖)へ上げる。

### 網羅の定義

- **網羅基準(段階的)**：まず 0-switch で全有効遷移と各状態の全無効イベントを踏む。必要な箇所だけ N-switch(遷移連鎖)へ上げる。
- **網羅手順**：
  1. 状態遷移表(状態 × イベント → 次状態)を作る。
  2. 表から有効遷移をすべて列挙する。
  3. 各状態について起こりうる全イベントを当て、有効でない分を無効遷移として列挙する。
- **達成チェック**：無効遷移(状態 × 来てはいけないイベント)が一つも欠けていないか確認する。
- 状態爆発する設計は、ここで全 interleaving を網羅しようとせず `loop-engineering`(TLA+)へ委ね、反例を遷移ケースとして落とす。

### 禁止仕様からのテスト導出(許可される列・禁止される列)

無効遷移は「ある状態で来てはいけない1イベント」を見る。これを**列**へ一般化すると、N-switch のケースを思いつきでなく機械的に作れる。観点は2つ。

- **禁止される列(拒否)**：本来到達不能なイベント列。最後まで流すと**途中で止まる/例外になる/状態が進まない**ことを確認する。例: `(注文作成 → 出荷)` は支払いを飛ばしているので拒否されねばならない。無効遷移の単発版を「そこへ至る列」へ伸ばしたもの。
- **許可される列(受理)**：本来到達できる正常列。最後まで流せて、各ステップで期待した次イベントが**受理可能**であることを確認する。例: `(作成 → 支払い → 出荷 → 配達)` が全段通る。

導出の起点は「来てはいけない振る舞い」のリスト。機能要求を「禁止される列の集合」として書き出すと、各禁止列が1本の拒否テストに、その境界にある正常列が受理テストに、ほぼ1対1で落ちる(`good-test-principles.md` の振る舞い→テストの橋渡しと同じ向き)。

```ts
describe("order state machine: traces", () => {
  const run = (events: string[]) => events.reduce((s, e) => next(s, e), "created");

  // 許可される列(受理): 最後まで流せる
  it("accepts (pay, ship, deliver)", () => {
    expect(run(["pay", "ship", "deliver"])).toBe("delivered");
  });

  // 禁止される列(拒否): 途中で止まる
  it("rejects (ship ...) — payment skipped", () => {
    expect(() => run(["ship", "deliver"])).toThrow();
  });
});
```

落とし穴: 禁止列を「異常系の入力1個」と同一視して単発に縮めてしまう。**履歴の途中まで正常で、ある一手で初めて禁止になる**列(連休跨ぎ、二重支払い、期限切れ後の操作)が N-switch の本命で、ここが単発検査からこぼれる。状態空間が広く禁止列の網羅性を厳密に押さえたいなら、列の生成は `loop-engineering`(TLA+)に任せ、反例トレースをそのまま拒否テストへ落とす。

---

## 原因結果グラフ(Cause-Effect Graph)

### 概要
入力条件(原因)と出力(結果)を論理ゲート(AND/OR/NOT)で結んだグラフを描き、そこから機械的にデシジョンテーブルを導出する。

### 目的/いつ使う
条件と結果の論理関係が複雑で、デシジョンテーブルを手で作ると組合せを取りこぼす恐れがあるとき。
グラフ化で論理の矛盾や冗長を先に発見できる。
関係が単純ならグラフは省き、直接デシジョンテーブルでよい(YAGNI)。

### TypeScript example
原因結果グラフ自体は設計の中間成果物で、最終的にはデシジョンテーブルへ落ちる。
そのテーブルを上記「デシジョンテーブル」と同じ `it.each` 形式でテストする。グラフから導いた論理式をコメントで残すと追跡しやすい。

```ts
import { describe, it, expect } from "vitest";
import { canWithdraw } from "./atm";

// cause-effect:
//   C1 = カード有効, C2 = 残高>=金額, C3 = 1日上限内
//   E(出金可) = C1 AND C2 AND C3
describe("canWithdraw: derived from cause-effect graph", () => {
  const t = true, f = false;
  const cases = [
    { c1: t, c2: t, c3: t, expected: true },
    { c1: f, c2: t, c3: t, expected: false },
    { c1: t, c2: f, c3: t, expected: false },
    { c1: t, c2: t, c3: f, expected: false },
  ] as const;

  it.each(cases)(
    "card=$c1 funds=$c2 limit=$c3 -> $expected",
    ({ c1, c2, c3, expected }) => {
      expect(canWithdraw(c1, c2, c3)).toBe(expected);
    },
  );
});
```

### 落とし穴
- グラフ作成のコストが高い。論理が単純な場面に持ち込むと、得るものより手間が勝つ。
- 制約(原因間の排他、包含)をグラフに書き落とすと、実現不可能な組合せをテストしてしまう。

### 網羅の定義

- **網羅基準**：グラフから導出したデシジョンテーブルの実現可能な全ルールを網羅したとき完了(デシジョンテーブルの基準を継承する)。
- **網羅手順**：
  1. 原因と結果を論理ゲート(AND/OR/NOT)でグラフ化する。
  2. 原因間の制約(排他、包含)をグラフへ反映する。
  3. グラフを機械的にデシジョンテーブルへ変換する。
  4. 残った各ルールを1ケースにする。
- **達成チェック**：制約で実現不可になる組合せをテストに混ぜていないか確認する。

---

## ペアワイズ/直交表(Pairwise / All-pairs)

### 概要
多数のパラメータの全組合せではなく、任意の2パラメータのすべての値の対(ペア)が少なくとも1度現れる最小集合に絞る。多くの欠陥が2要因の相互作用で起きるという経験則に依拠する。

### 目的/いつ使う
独立した設定項目が多くて全組合せが爆発するとき(OS × ブラウザ × 言語 × 通貨 など)。
3要因以上の相互作用が疑われる箇所には不向き(その部分だけ高次の網羅を別途用意する)。

### TypeScript example
ペアワイズの組合せ生成はツール(`@fast-check/...` や allpairs 系)で作るのが筋。
ここでは生成済みのペアワイズ表をテストデータとして読み込み回す形を示す。

```ts
import { describe, it, expect } from "vitest";
import { render } from "./checkout";
import pairs from "./checkout.pairwise.json"; // ツールで生成した最小組合せ表

describe("checkout: pairwise coverage", () => {
  it.each(pairs)("%o renders without error", (combo) => {
    expect(() => render(combo)).not.toThrow();
  });
});
```

### 落とし穴
- 「2要因で十分」は経験則。既知の3要因バグがあるなら、その組はペアワイズと別に明示追加する。
- 手で最小集合を組もうとしない。最小化は組合せ最適化で、ツールに任せる。

### 網羅の定義

- **網羅基準**：任意の2パラメータ間の全値ペアが少なくとも1度現れたとき網羅完了(2-way カバレッジ100%)。
- **網羅手順**：
  1. パラメータとその値域を列挙する。
  2. 実現不可な値の組合せを制約として定義する。
  3. covering array をツールで生成する。
  4. 生成表の各行を1ケースにする。
- **達成チェック**：既知の3要因バグがペアワイズと別に明示追加されているか確認する。
- 組合せ生成が手作業でなくツール出力になっているか(手で組むとペア漏れが残る)を見る。

---

## クラシフィケーションツリー法(Classification Tree Method)

### 概要
テスト対象の入力をいくつかの分類(classification)に分け、各分類を同値クラスへ細分してツリーで可視化し、ツリーの葉の組合せからテストケースを選ぶ。同値分割を多次元へ構造化したもの。

### 目的/いつ使う
入力が複数の独立した側面を持ち、各側面ごとに区分が要るとき(画像処理で、フォーマット × サイズ × カラーモード)。
ツリーで網羅状況を見ながら、ペアワイズ等と組み合わせて組合せ数を制御できる。
側面が1つなら単なる同値分割で足りる。

### TypeScript example
分類(フォーマット/サイズ)とその葉を配列で持ち、選んだ組合せを `it.each` で回す。ツリーは設計図、テストはその葉の選択。

```ts
import { describe, it, expect } from "vitest";
import { thumbnail } from "./image";

// classification tree:
//   format: [png, jpeg, webp]
//   size:   [empty, small, huge]
const selected = [
  { format: "png", size: "small", ok: true },
  { format: "jpeg", size: "huge", ok: true },
  { format: "webp", size: "empty", ok: false },
] as const;

describe("thumbnail: classification tree leaves", () => {
  it.each(selected)("$format/$size -> ok=$ok", ({ format, size, ok }) => {
    expect(thumbnail(format, size).ok).toBe(ok);
  });
});
```

### 落とし穴
- 分類が直交していない(side effect で絡む)と葉の組合せが誤誘導になる。分類軸の独立性を先に確かめる。
- 葉を全組合せで取ると爆発する。ペアワイズや優先度で間引く。

### 網羅の定義

- **網羅基準**：選んだ組合せ戦略(全葉単独、2-way、優先度)に対し、その戦略が要求する葉の選択をすべて踏んだとき網羅完了。
- **網羅手順**：
  1. 入力を独立した分類軸へ分ける。
  2. 各軸を同値クラスへ細分する。
  3. ツリーの葉を列挙する。
  4. 組合せ戦略を選び、その戦略に従って葉の組合せを選択し1ケースずつにする。
- **達成チェック**：分類軸どうしの独立性が確かめてあるか確認する。
- 葉の全組合せが爆発する場合、戦略(ペアワイズ、優先度)で間引けているかを見る。
