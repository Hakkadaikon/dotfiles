# モダン/自動生成・性質ベースのテスト

人間が個別のケースを書き並べる代わりに、性質や生成器、別実装、モデルに「正しさの判定」を委ねるテスト群。
古典のブラックボックス技法が「この入力でこの出力」を1つずつ固定するのに対し、ここでは「どんな入力でも成り立つ関係」や「信頼できる基準との一致」を確かめる。

これらの多くは **oracle 問題**(期待値をどう用意するか)への異なる解として読むと筋が通る。
期待値を1つずつ手で書けない/書きたくないとき、性質で縛る(PBT・メタモルフィック)、別の信頼できる実装と突き合わせる(差分)、過去の出力を基準に固める(スナップショット・承認)、のどれを選ぶかという軸で整理する。

## 目次

- [プロパティベーステスト(Property-Based Testing)](#プロパティベーステストproperty-based-testing)
- [ファジング(Fuzzing)](#ファジングfuzzing)
- [カバレッジガイデッドファジング(Coverage-Guided Fuzzing)](#カバレッジガイデッドファジングcoverage-guided-fuzzing)
- [ゴールデンテスト/スナップショットテスト](#ゴールデンテストスナップショットテスト)
- [承認テスト(Approval Testing)](#承認テストapproval-testing)
- [差分テスト(Differential Testing)](#差分テストdifferential-testing)
- [メタモルフィックテスト(Metamorphic Testing)](#メタモルフィックテストmetamorphic-testing)
- [モデルベーステスト(Model-Based Testing)](#モデルベーステストmodel-based-testing)
- [形式検証連携(TLA+/Lean → 述語テスト)](#形式検証連携tlalean--述語テスト)
- [コンビナトリアルテスト(Combinatorial Testing)](#コンビナトリアルテストcombinatorial-testing)
- [AI/LLM 支援テスト生成(信頼は限定的)](#aillm-支援テスト生成信頼は限定的)

---

## プロパティベーステスト(Property-Based Testing)

### 概要
個別の入力例ではなく、入力全体に対して成り立つべき性質(不変条件)を宣言し、ライブラリが多数のランダム入力を生成して反例を探す。

### 目的/いつ使う
「逆関数の往復で元に戻る」「可換」「結果は常にソート済み」のように、出力そのものより入力と出力の関係を言えるときに使う。
反例が見つかると自動で最小化(shrink)され、最小の壊れる入力が手に入る。
逆に成り立つ性質が「実装をそのまま書き写しただけ」になるなら oracle になっておらず、無価値なので使わない。

### TypeScript example
JSON エンコード/デコードの往復(round-trip)を性質として叩く。

```ts
import { describe, it, expect } from "vitest";
import fc from "fast-check";
import { encode, decode } from "./codec";

describe("codec: properties", () => {
  it("round-trips any value (decode . encode = id)", () => {
    fc.assert(
      fc.property(fc.jsonValue(), (value) => {
        expect(decode(encode(value))).toStrictEqual(value);
      }),
    );
  });
});
```

### 落とし穴
- 生成器が狭いと(正の整数だけ等)肝心の境界・異常値を踏まず、緑なのに穴が残る。`fc.jsonValue` のように広い生成器を選ぶ。
- 性質が実装の写し(同じロジックで期待値を作る)になると、両方同時に間違っても通る。

### 網羅の定義
- **網羅基準**: 対象の正しさを縛る性質(不変条件)集合を全て property 化し、各 property を十分広い生成器で多数試行して反例ゼロ。
- **網羅手順**:
  1. 対象に成り立つ性質を列挙する(往復・可換・不変・結果制約)。
  2. 各性質を `fc.property` のアサーションへ落とす。
  3. 生成器を入力空間に合わせて広く取る(狭い生成器は穴を残す)。
- **達成チェック**: 生成器が境界・異常値を踏むか確認する。性質が実装の写しになっていないか(独立した oracle として成立しているか)を見る。

---

## ファジング(Fuzzing)

### 概要
不正・極端・ランダムなバイト列や文字列を大量に流し込み、クラッシュ・ハング・assertion 違反・未処理例外を起こす入力を探す。

### 目的/いつ使う
パーサー、デシリアライザ、入力検証、ファイル/プロトコル境界など「信頼できない入力」を受ける箇所の頑健性を確かめる。
判定は「壊れないこと」(落ちない・無限ループしない・不変条件を保つ)で済むので、出力の正解が要らないのが利点。
出力の意味的正しさまで問いたいなら、ファジングではなく PBT やメタモルフィックを使う。

### TypeScript example
fast-check をファザーとして使い、任意文字列でパーサーが例外を投げず必ず判定を返すことを確認する。

```ts
import { describe, it, expect } from "vitest";
import fc from "fast-check";
import { parseConfig } from "./config";

describe("parseConfig: fuzzing", () => {
  it("never throws and always returns ok|error for any string", () => {
    fc.assert(
      fc.property(fc.string(), (raw) => {
        const r = parseConfig(raw); // 例外を投げたらここで失敗扱い
        expect(r.kind === "ok" || r.kind === "error").toBe(true);
      }),
    );
  });
});
```

### 落とし穴
- 「落ちない」だけを見ると、黙って誤った値を返すバグはすり抜ける。不変条件チェックを併せて入れる。
- 反例の再現にはシード固定が要る。fast-check は失敗時にシードを出すので控える。

### 網羅の定義
- **網羅基準**: 信頼できない入力境界に対し、クラッシュ・ハング・未処理例外・不変条件違反を起こす入力が見つからない状態(到達した分岐とコーパスで近似)。
- **網羅手順**:
  1. 入力源を fast-check 等で広く生成する。
  2. 「落ちない・必ず判定を返す・不変条件を保つ」を assert する。
  3. 失敗時はシードを保存し回帰の種にする。
- **達成チェック**: 「落ちない」だけでなく不変条件チェックを併載しているか確認する(黙って誤値を返すバグはこれが無いとすり抜ける)。

---

## カバレッジガイデッドファジング(Coverage-Guided Fuzzing)

### 概要
実行時のコードカバレッジを計測し、新しい経路を開拓した入力を「種」として残して変異させる。
ランダムな総当たりより遥かに速く深いパスへ到達する(AFL/libFuzzer 系の発想)。

### 目的/いつ使う
パーサーやバイナリ処理など分岐が深く、素朴なランダム入力では奥まで届かない対象に使う。
JS/TS では `@jazzer.js` や `jsfuzz` がカバレッジ計装つきのファザーを提供する。
分岐が浅く入力空間も狭いなら、計装のコストに見合わないので通常のファジングや PBT で足りる。

### TypeScript example
`@jazzer.js` のファズターゲットの最小形(専用ランナー `jazzer` で起動し、コーパスを育てる)。

```ts
// fuzz/parse.fuzz.ts  ->  npx jazzer fuzz/parse.fuzz.ts
import { FuzzedDataProvider } from "@jazzer.js/core";
import { parseConfig } from "../config";

export function fuzz(data: Buffer) {
  const provider = new FuzzedDataProvider(data);
  const raw = provider.consumeRemainingAsString();
  const r = parseConfig(raw);
  // 不変条件: 必ず判定が返る。破れたら throw してクラッシュ扱いにする
  if (r.kind !== "ok" && r.kind !== "error") throw new Error("invalid result");
}
```

### 落とし穴
- 計装つき実行は通常のユニットテストと別ランナー・別 CI ジョブになる。常時 CI に乗せるか、夜間ジョブに回すか先に決める。
- 育てたコーパスを捨てると毎回ゼロから探索になる。コーパスは保存して回帰の種に使う。

### 網羅の定義
- **網羅基準**: 新規経路を開拓する入力が枯れる(カバレッジが頭打ちになる)まで探索し、育てたコーパスで網羅を近似する。
- **網羅手順**:
  1. `jazzer.js` 等でコードを計装する。
  2. ファズターゲットを定義する。
  3. コーパスを育て、新しい経路が出なくなるまで回す。
- **達成チェック**: 計装ランナーを別 CI ジョブに分けているか、コーパスを保存して回帰の種にしているかを確認する。

---

## ゴールデンテスト/スナップショットテスト

### 概要
出力を初回に「ゴールデン(基準)」として保存し、以降は現在の出力との差分で合否を判定する。

### 目的/いつ使う
レンダリング結果・整形出力・コード生成・大きな構造体など、期待値を手で書くより一度確定させて固定したいときに使う。
差分が出たら「バグか、意図した変更か」を人が判断し、後者なら基準を更新する。
出力が非決定的(時刻・乱数・順序不定)なものは正規化しないと毎回壊れるので、その前処理が無いなら使わない。

### TypeScript example
整形関数の出力をスナップショットに固定する。

```ts
import { describe, it, expect } from "vitest";
import { renderInvoice } from "./invoice";

describe("renderInvoice: snapshot", () => {
  it("matches the golden output", () => {
    const out = renderInvoice({ id: 7, items: [{ name: "pen", qty: 3 }] });
    expect(out).toMatchSnapshot();
  });
});
```

### 落とし穴
- 差分を読まずに `--update` で機械的に承認すると、バグごと基準を上書きする。更新は必ず差分を見てから。
- 巨大スナップショットは差分が読めず形骸化する。意味のある単位に分けるか、要点だけを固定する。

### 網羅の定義
- **網羅基準**: 網羅対象(レンダリング・整形・生成の代表入力集合)それぞれにゴールデンが存在し、現出力との差分がゼロ。
- **網羅手順**:
  1. 代表入力を同値分割で選ぶ。
  2. 各出力をスナップショットに固定する。
  3. 差分が出たらバグか意図変更かを人が判断する。
- **達成チェック**: 非決定要素(時刻・乱数・順序)を正規化済みか確認する。巨大スナップショットで差分が読めず形骸化していないかを見る。

---

## 承認テスト(Approval Testing)

### 概要
スナップショットの一般形。
出力(テキスト・画像・任意の成果物)を「承認済み」ファイルとして保持し、現在の出力と突き合わせ、差分を専用のビューアで人がレビューして承認する。

### 目的/いつ使う
レガシーコードの現状を素早く固定して安全網を張りたいとき(characterization test)や、複雑な成果物を都度レビューで通したいときに使う。
判定基準は「人が見て OK と言った状態との一致」なので、仕様が未文書でも始められる。
仕様が明確で期待値を直接書けるなら、承認の往復を挟まずアサーションで書くほうが速い。

### TypeScript example
承認ツール(例: `approvals`)に成果物を渡す。初回は `received` を生成し、人が `approved` にリネーム/承認して基準化する。

```ts
import { describe, it } from "vitest";
import { verify } from "approvals/lib/Providers/Jest/JestApprovals";
import { generateReport } from "./report";

describe("generateReport: approval", () => {
  it("matches approved report", () => {
    // 差分があれば received と approved を並べて提示し、人が承認するまで失敗
    verify(generateReport({ region: "jp", year: 2026 }));
  });
});
```

### 落とし穴
- 承認の主体が曖昧だと「とりあえず承認」が横行し、基準が腐る。誰が何を見て承認したかを運用で担保する。
- 非決定的出力はスナップショット同様、承認前に正規化(日時・ID のマスク)が要る。

### 網羅の定義
- **網羅基準**: 網羅対象の各成果物に承認済み版があり、現在の出力と一致する。
- **網羅手順**:
  1. 対象成果物を列挙する。
  2. received を生成する。
  3. 人がレビューし approved 化する。
- **達成チェック**: 承認の主体と根拠が運用で担保されているか、非決定要素をマスク済みかを確認する。レガシー固定(characterization)では現状の振る舞い集合を網羅対象に取る。

---

## 差分テスト(Differential Testing)

### 概要
同じ入力を信頼できる別実装(参照実装・旧版・別ライブラリ)にも流し、両者の出力が一致するかで判定する。

### 目的/いつ使う
期待値を自前で書けないが、正しいと信じられる別実装があるとき(最適化版 vs 素朴版、自作 vs 標準ライブラリ、移植元 vs 移植先)に使う。
oracle 問題を「もう一つの実装」で解くのが本質。
参照実装が無い、あるいは両実装が同じ前提で同じ間違いをし得るなら、一致しても正しさの保証にならない。

### TypeScript example
最適化版 `fastSum` を、素朴な参照実装と任意入力で突き合わせる(PBT と組み合わせると強い)。

```ts
import { describe, it, expect } from "vitest";
import fc from "fast-check";
import { fastSum } from "./fast-sum";

const refSum = (xs: number[]) => xs.reduce((a, b) => a + b, 0);

describe("fastSum: differential vs reference", () => {
  it("agrees with the naive implementation on any int array", () => {
    fc.assert(
      fc.property(fc.array(fc.integer()), (xs) => {
        expect(fastSum(xs)).toBe(refSum(xs));
      }),
    );
  });
});
```

### 落とし穴
- 両実装が同じ仕様の穴(同じ丸め誤差・同じ未定義動作の解釈)を共有すると、一致してもバグは残る。独立性が命。
- 浮動小数は厳密一致しないことがある。許容誤差での比較に切り替える。

### 網羅の定義
- **網羅基準**: 信頼できる参照実装と、入力空間を代表する入力集合(PBT 併用で多数)で全件一致する。
- **網羅手順**:
  1. 参照実装を用意する。
  2. 同じ入力を両者へ流す。
  3. 出力一致を assert し、PBT で入力を広く取る。
- **達成チェック**: 両実装が同じ穴を共有していないか(独立性)を確認する。浮動小数は許容誤差で比較する。

---

## メタモルフィックテスト(Metamorphic Testing)

### 概要
単一入力の正解が分からなくても、「入力をこう変換したら出力はこう変わる(変わらない)はず」という関係(metamorphic relation)で検証する。

### 目的/いつ使う
oracle が無い対象(検索ランキング、数値計算、機械学習推論、最適化)で有効。
正解そのものではなく入力変換と出力の関係を縛るので、期待値を一切用意せずに矛盾を炙り出せる。
出力の絶対値を直接アサートできるなら、わざわざ関係に置き換える必要はない。

### TypeScript example
ソートの metamorphic relation: 入力を並べ替えても出力は不変、長さも不変。

```ts
import { describe, it, expect } from "vitest";
import fc from "fast-check";
import { sortAsc } from "./sort";

describe("sortAsc: metamorphic relations", () => {
  it("output is invariant under input permutation and preserves length", () => {
    fc.assert(
      fc.property(fc.array(fc.integer()), (xs) => {
        const shuffled = [...xs].reverse();
        expect(sortAsc(shuffled)).toStrictEqual(sortAsc(xs));
        expect(sortAsc(xs)).toHaveLength(xs.length);
      }),
    );
  });
});
```

### 落とし穴
- 関係が弱いと(長さ不変だけ等)中身が壊れていても通る。複数の関係を重ねて締める。
- 思い込みの関係(本当は成り立たない)を入れると偽陽性を量産する。関係の根拠は仕様に置く。

### 網羅の定義
- **網羅基準**: 対象に成り立つ metamorphic relation 集合を全て検査し、各 relation が広い入力で破れない。
- **網羅手順**:
  1. 入力変換と出力変化の関係を仕様から複数導く。
  2. 各関係を property 化する。
  3. 広い生成器で多数試行する。
- **達成チェック**: 関係が弱すぎ(長さ不変だけ等)て中身の破れを見逃さないか確認する。各関係の根拠が仕様にあるか、複数関係を重ねて締めているかを見る。

---

## モデルベーステスト(Model-Based Testing)

### 概要
システムの振る舞いを抽象モデル(状態機械など)で表し、そこからテスト系列(操作の列)を自動生成して実システムと突き合わせる。

### 目的/いつ使う
操作の順序・履歴に依存する対象(プロトコル、ステートフルな API、UI フロー、データ構造)で、人手では思いつかない操作列を網羅したいときに使う。
モデル側を oracle として、各操作後にモデルと実装の状態が一致するかを判定する。
状態も順序も無い純粋関数には過剰。通常の PBT で足りる。

### TypeScript example
fast-check の `commands`(ステートフル PBT)で、モデルと実装を操作列で並走させる擬似コード。

```ts
// model: 期待される振る舞いの最小実装(oracle)
// real:  テスト対象(例: LRU キャッシュ)
// fast-check が put/get の操作列をランダム生成し、各操作後に invariant を照合する
fc.assert(
  fc.property(fc.commands([PutCommand(), GetCommand()]), (cmds) => {
    const model = { map: new Map() };          // 参照モデル
    const real = newCache();                   // 実装
    fc.modelRun(() => ({ model, real }), cmds); // 各 Command の check/run で両者を比較
  }),
);
```

### 落とし穴
- モデルが実装と同程度に複雑だと、モデル自身がバグの温床になり oracle の信頼が崩れる。モデルは意図的に素朴に保つ。
- 操作列が長くなると失敗の再現・最小化が重い。shrink が効く範囲に操作を絞る。

### 網羅の定義
- **網羅基準**: モデル(状態機械)から生成した操作列で、到達したモデル状態・遷移を網羅し、各操作後にモデルと実装が一致する。
- **網羅手順**:
  1. 抽象モデルを定義する。
  2. `fast-check` の commands 等で操作列を生成する。
  3. 各操作後に invariant を照合する。
- **達成チェック**: モデルが素朴に保たれ oracle の信頼が崩れていないか確認する。操作列が長すぎて shrink が効かなくないかを見る。

---

## 形式検証連携(TLA+/Lean → 述語テスト)

### 概要
上流の形式手法で確立した不変条件・証明済み述語を、そのまま実装に対する property-based test の property として叩き、設計とコードの間を埋める。

### 目的/いつ使う
設計や数学的性質を形式手法で固めた後、その性質が実装でも成り立つことを継続的に確かめたいときに使う。
このリポジトリの姉妹スキルと接続する:

- `loop-engineering`(TLA+ で状態遷移・並行・プロトコルの設計を網羅検査し、反例を Gherkin の受け入れ仕様へ落とす)。
  TLA+ の安全性不変条件(例: 「同時にロックを保持するのは高々1者」)を、実装の操作列に対する property として再表現する。
  反例から生まれた Gherkin シナリオは、そのまま具体例のテストになる。
- `formal-verification`(Lean 4 でアルゴリズム・セキュリティ性質を証明)。
  Lean で証明した定理(例: `decode (encode x) = x`、入力検証の健全性、分類の網羅性)を、PBT の property として実装に対して走らせる。

形式手法は性質が「数学的に正しい」ことを保証するが、その性質が**目の前の実装で**成り立つかは別問題。
PBT はその橋渡し層であり、証明済み述語を実装にぶつけて乖離を検出する。
TLA+/Lean を回していない素のロジックに、わざわざこの連携を持ち込む必要はない(YAGNI)。

### TypeScript example
Lean で証明済みの述語「decode は encode の左逆元」を、実装に対する property としてそのまま叩く。

```ts
import { describe, it, expect } from "vitest";
import fc from "fast-check";
import { encode, decode } from "./codec";

// Lean で証明済み: ∀ x, decode (encode x) = x
// 同じ述語を実装に対する property として実行し、設計と実装の乖離を検出する
describe("codec: bridges the proven invariant", () => {
  it("decode is a left inverse of encode (proven in Lean)", () => {
    fc.assert(
      fc.property(fc.jsonValue(), (x) => {
        expect(decode(encode(x))).toStrictEqual(x);
      }),
    );
  });
});
```

### 落とし穴
- 形式モデルと実装の型・粒度がずれると、同じ名前でも別の性質を検査してしまう。述語の対応を1対1で明記する。
- 証明済みだからとテストを省くと、モデルに無い実装上の前提(I/O、並行、リソース)が抜ける。橋渡しテストは省略しない。

### 網羅の定義
- **網羅基準**: 上流(TLA+/Lean)で確立した不変条件・証明済み述語を全て実装への property として叩き、乖離ゼロ。
- **網羅手順**:
  1. TLA+ の安全性不変条件と Lean の定理を列挙する。
  2. 各述語を実装の操作列・入力に対する property へ1対1で写す。
  3. 反例由来の Gherkin を具体例テストにする。
- **達成チェック**: モデルと実装で型・粒度がずれて別性質を検査していないか確認する。証明済みでも橋渡しテストを省かない。

---

## コンビナトリアルテスト(Combinatorial Testing)

### 概要
複数のパラメータが取り得る値の全組合せではなく、任意の t 個のパラメータの値の組合せを必ず一度は含む小さな集合(t-way / covering array)を自動生成する。

### 目的/いつ使う
設定フラグ・対応環境・入力カテゴリなど独立パラメータが多く、全組合せが爆発するときに使う。
欠陥の多くは少数パラメータの相互作用で起きるという経験則により、2-way(pairwise)で大半を、3-way で更に深い相互作用を、現実的なケース数で押さえる。
パラメータ間に強い依存(ある値が別の値を無効化する)があるなら制約を入れずに使うと無効ケースを量産するので、制約対応の生成器が要る。

### TypeScript example
`@fast-check/vitest` などにある pairwise 生成を使い、3パラメータの 2-way 組合せを回す。

```ts
import { describe, it, expect } from "vitest";
import { pairwise } from "./pairwise"; // covering array を返す小関数 or ライブラリ

const os = ["linux", "mac", "win"] as const;
const node = ["18", "20", "22"] as const;
const mode = ["dev", "prod"] as const;

describe("build matrix: 2-way coverage", () => {
  it.each(pairwise(os, node, mode))("builds on %s/node%s/%s", (o, n, m) => {
    expect(build({ os: o, node: n, mode: m }).ok).toBe(true);
  });
});
```

### 落とし穴
- t を上げるほどケース数が急増する。まず 2-way で測り、相互作用バグが残る箇所だけ 3-way に上げる。
- 無効な値の組合せを除外する制約を入れないと、生成されたケースの多くが意味を成さない。

### 網羅の定義
- **網羅基準**: 選んだ強さ t に対する t-way covering array が全ての t-組合せを含む(まず 2-way、相互作用が疑わしい箇所だけ 3-way)。
- **網羅手順**:
  1. パラメータと値域を洗い出す。
  2. 無効組合せを除く制約を定義する。
  3. t-way covering array を生成し、各行を1ケースにする。
- **達成チェック**: 制約で無効組合せを除外しているか確認する。t を上げる範囲を、相互作用バグの残る箇所に絞れているかを見る。

---

## AI/LLM 支援テスト生成(信頼は限定的)

### 概要
LLM にコードを渡してテストケースやアサーションを生成させる。
ケースの叩き台や見落とした観点の洗い出しには速いが、生成物の正しさは保証されない。

### 目的/いつ使う
テストの初稿、命名、定型的な it.each の量産、観点のブレインストーミングに使う。
**但し書き(必須): LLM が生成したアサーションは、実装の現在の挙動をそのまま「正解」と思い込んで固定しがちで、バグごと緑にする。生成テストは必ず人がレビューし、期待値の根拠を仕様に照らして確認する。** oracle を LLM に委ねてはならない。
正しさを数学的・網羅的に保証したい critical な箇所には使わず、PBT・差分・形式検証連携を使う。

### 手順(コード化しにくいので手順で)
1. 対象関数のシグネチャと仕様(あれば)を渡し、観点(正常・境界・異常)ごとにケース候補を出させる。
2. 生成された期待値を**実装ではなく仕様**と突き合わせて検証する。実装と一致するだけのアサーションは捨てる。
3. 性質として一般化できるものは PBT へ、相互作用はコンビナトリアルへ昇格させ、具体例だけを手書きテストに残す。
4. レビューを通ったものだけコミットする。生成のまま無検証で取り込まない。

### 落とし穴
- 生成アサーションが現状の実装を追認するだけになり、回帰検出はできてもバグ検出ができない。
- もっともらしいが微妙に誤った期待値を量産する。レビューのコストを織り込まないと「テストはあるのに守られていない」状態になる。

### 「網羅」の扱い(網羅は主張しない)
- **なぜ網羅を定義できないか**: 生成は確率的で観点の全数を保証できず、合否(oracle)を LLM に委ねるとバグごと緑化するため。
- **停止規範**: 観点リスト(正常・境界・異常)を人が定義し、それを LLM 出力で埋めたかを人がチェックしたら打ち切る。各生成アサーションは実装ではなく仕様と突き合わせる。
- **体系的技法への昇格**: 性質化できるものは PBT、相互作用はコンビナトリアル、具体例だけ手書きへ移し、レビューを通ったものだけコミットする。網羅の保証はあくまで昇格先の A型技法が担う。
