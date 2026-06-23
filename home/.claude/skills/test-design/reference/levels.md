# テストレベル

対象の粒度によるテストの分類。
下に行くほど対象が広く、実行が遅く、本物の環境に近い。
ISO/IEC/IEEE 29119 が用語の基準だが、現場では下記の俗称が混在するため、各手法で「何を本物にし、何を差し替えるか」を明確にして選ぶ。

## 目次

- [単体テスト(Unit Test)](#単体テストunit-test)
- [結合テスト(Integration Test)](#結合テストintegration-test)
- [コンポーネントテスト](#コンポーネントテスト)
- [コントラクトテスト(Consumer-Driven Contract / Pact)](#コントラクトテストconsumer-driven-contract--pact)
- [システムテスト](#システムテスト)
- [E2E テスト(Playwright 例)](#e2e-テストplaywright-例)
- [受け入れテスト(UAT)](#受け入れテストuat)
- [スモークテスト](#スモークテスト)
- [サニティテスト](#サニティテスト)
- [回帰テスト](#回帰テスト)
- [補足: テストピラミッド vs テストトロフィー(配分論)](#補足-テストピラミッド-vs-テストトロフィー配分論)

## 単体テスト(Unit Test)

### 概要
関数・メソッド・クラスといった最小単位を、依存を切り離して検証する。

### 目的/いつ使う
ロジックの分岐・境界・例外を高速かつ大量に回したいときに使う。
外部 I/O やフレームワークの挙動そのものを確かめたい局面では使わない(それは結合より上の責務)。

### TypeScript example
```ts
import { describe, it, expect } from "vitest";

// 検証対象: 純粋関数。依存なしなのでそのまま呼べる
function applyDiscount(price: number, rate: number): number {
  if (rate < 0 || rate > 1) throw new RangeError("rate out of range");
  return Math.round(price * (1 - rate));
}

describe("applyDiscount", () => {
  it("割引を適用して四捨五入する", () => {
    expect(applyDiscount(1000, 0.1)).toBe(900);
  });
  it("境界: rate=1 は 0 円", () => {
    expect(applyDiscount(1000, 1)).toBe(0);
  });
  it("異常系: 範囲外の rate は例外", () => {
    expect(() => applyDiscount(1000, 1.5)).toThrow(RangeError);
  });
});
```

### 落とし穴
モックを積み上げて実装の呼び出し順をなぞるテストは、リファクタで即壊れる割に欠陥を捕まえない。
private メソッドを直接叩こうとするのは設計のにおい。公開された振る舞いで検証する。

## 結合テスト(Integration Test)

### 概要
複数のモジュールや、コードと実依存(DB・キュー・別サービス)の境界をまたいで検証する。

### 目的/いつ使う
単体では見えない接続部のずれ(SQL の方言、シリアライズ、トランザクション境界)を捕まえたいときに使う。
ロジックの全分岐を網羅する用途には向かない(遅く、組み合わせ爆発する)。

### TypeScript example
```ts
import { describe, it, expect, beforeAll, afterAll } from "vitest";
import Database from "better-sqlite3";
import { UserRepo } from "./user-repo";

let db: Database.Database;
let repo: UserRepo;

beforeAll(() => {
  // 本物の DB エンジンを使う。スキーマのずれをここで検出する
  db = new Database(":memory:");
  db.exec("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL)");
  repo = new UserRepo(db);
});
afterAll(() => db.close());

describe("UserRepo", () => {
  it("保存した行を取得できる", () => {
    const id = repo.insert("alice");
    expect(repo.findById(id)?.name).toBe("alice");
  });
});
```

### 落とし穴
共有 DB を使い回してテスト間で状態が漏れると、実行順で結果が変わる不安定なテストになる。
in-memory で代用すると本番 DB との方言差を見逃すことがある。重要な経路は本物のエンジンで確認する。

## コンポーネントテスト

### 概要
1 つのサービスやモジュール群を 1 単位として、外部依存だけスタブ化して内部は本物のまま検証する。

### 目的/いつ使う
あるサービスを独立にデプロイ可能な箱とみなし、その箱単体の振る舞いを契約として固めたいときに使う。
複数サービスの連携全体を見たい局面では使わない(それはシステムテスト)。

### TypeScript example
```ts
import { describe, it, expect, vi } from "vitest";
import { OrderService } from "./order-service";

describe("OrderService(コンポーネント)", () => {
  it("在庫があれば注文を確定する", async () => {
    // 外部の決済 API だけスタブ。サービス内部のロジックは本物
    const payment = { charge: vi.fn().mockResolvedValue({ ok: true }) };
    const svc = new OrderService(payment);
    const result = await svc.placeOrder({ sku: "A1", qty: 2 });
    expect(result.status).toBe("confirmed");
    expect(payment.charge).toHaveBeenCalledOnce();
  });
});
```

### 落とし穴
スタブの返す形が実物の API とずれると、緑のまま本番で壊れる。
ここをコントラクトテストで裏打ちしないと、コンポーネント単体の安心は錯覚になる。

## コントラクトテスト(Consumer-Driven Contract / Pact)

### 概要
サービス間の API 契約(リクエスト/レスポンスの形)を、消費側が定義し提供側が満たすことを両端で検証する。

### 目的/いつ使う
マイクロサービスやチーム分割で、相手を立ち上げずに連携の互換性を担保したいときに使う。
単一プロセス内の呼び出しや、めったに変わらない安定 API には過剰。

### TypeScript example
```ts
import { PactV3, MatchersV3 } from "@pact-foundation/pact";
import { describe, it, expect } from "vitest";
import path from "node:path";
import { fetchUser } from "./user-client";

const { like } = MatchersV3;

describe("user-client の契約", () => {
  it("GET /users/:id がユーザーを返す", async () => {
    const provider = new PactV3({
      consumer: "web",
      provider: "user-api",
      dir: path.resolve(process.cwd(), "pacts"),
    });
    // 消費側が期待する形を宣言。提供側はこの pact ファイルで検証する
    provider
      .uponReceiving("a request for user 1")
      .withRequest({ method: "GET", path: "/users/1" })
      .willRespondWith({
        status: 200,
        body: { id: like(1), name: like("alice") },
      });

    await provider.executeTest(async (mock) => {
      const user = await fetchUser(mock.url, 1);
      expect(user.name).toBe("alice");
    });
  });
});
```

### 落とし穴
生成した pact を提供側の CI で検証しないと、契約はただのモック設定に堕ちる。
`like` で型だけ緩く合わせると、必須フィールドの欠落を見逃す。重要な値は具体例で固定する。

## システムテスト

### 概要
統合された全体を本番に近い構成で立ち上げ、外部から見た機能・性能・セキュリティを検証する。

### 目的/いつ使う
複数サービス・DB・設定が組み合わさった状態で要件を満たすかを、リリース前に確かめたいときに使う。
個別ロジックのデバッグには向かない(遅く、失敗箇所の切り分けが難しい)。

### TypeScript example
```ts
import { describe, it, expect } from "vitest";

// 起動済みの全システムに HTTP で外から触る。内部実装には一切触れない
const BASE = process.env.SYSTEM_URL ?? "http://localhost:8080";

describe("注文フロー(システム)", () => {
  it("注文を作成すると 201 と ID を返す", async () => {
    const res = await fetch(`${BASE}/orders`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ sku: "A1", qty: 1 }),
    });
    expect(res.status).toBe(201);
    const body = await res.json();
    expect(body.id).toBeTypeOf("string");
  });
});
```

### 落とし穴
環境差(設定・データ・依存サービスのバージョン)で落ちると、原因究明にコードより時間を食う。
あらゆる分岐をここで網羅しようとすると遅さで破綻する。網羅は下層に任せ、ここは代表経路に絞る。

## E2E テスト(Playwright 例)

### 概要
実ブラウザを使い、ユーザーの操作と同じ経路で UI から裏側まで通しで検証する。

### 目的/いつ使う
ログインから購入完了までの主要な利用シナリオが壊れていないことを保証したいときに使う。
細かい表示条件やバリデーションの全パターンには使わない(遅く脆い。単体/コンポーネントへ寄せる)。

### TypeScript example
```ts
import { test, expect } from "@playwright/test";

test("ログインしてダッシュボードに到達する", async ({ page }) => {
  await page.goto("/login");
  await page.getByLabel("メールアドレス").fill("alice@example.com");
  await page.getByLabel("パスワード").fill("secret");
  await page.getByRole("button", { name: "ログイン" }).click();
  // URL とロールで到達を確認。実装詳細ではなく見える状態を assert する
  await expect(page).toHaveURL(/\/dashboard/);
  await expect(page.getByRole("heading", { name: "ダッシュボード" })).toBeVisible();
});
```

### 落とし穴
`waitForTimeout` の固定待ちや CSS セレクタ依存は、flaky と保守コストの主因。
ロール・ラベルで要素を取り、自動待機(`expect(...).toBeVisible()`)に任せる。
シナリオを増やしすぎると CI が肥大する。E2E はピラミッドの頂点、本数を絞る。

## 受け入れテスト(UAT)

### 概要
発注者やユーザー視点で、要件・受け入れ基準を満たすかを判定する。自動化する場合は Gherkin など業務語彙で書く。

### 目的/いつ使う
「作ったもの」ではなく「望まれたもの」になっているかを、ビジネス側と合意した基準で確認したいときに使う。
技術的な内部品質の検証には使わない(それは開発側のテストの責務)。

### TypeScript example
```ts
import { describe, it, expect } from "vitest";
import { checkout } from "./checkout";

// 受け入れ基準を業務の言葉でテスト名にし、外から見た結果だけを判定する
describe("受け入れ: クーポン適用", () => {
  it("有効なクーポンを使うと合計が割引額だけ下がる", () => {
    const before = checkout({ items: [{ price: 1000 }] });
    const after = checkout({ items: [{ price: 1000 }], coupon: "OFF200" });
    expect(before.total - after.total).toBe(200);
  });
});
```

### 落とし穴
受け入れ基準が曖昧なまま自動化すると、何を合意したのか後から誰も言えなくなる。
開発者だけで書いた UAT は「自分が作った仕様の再確認」になりがち。基準はビジネス側と先に固める。

## スモークテスト

### 概要
ビルドやデプロイ直後に、最重要機能がそもそも起動・動作するかを最短で確認する。

### 目的/いつ使う
詳細テストを回す価値があるかの足切りに使う。デプロイ後のヘルスチェックにも使う。
網羅的な検証には使わない(目的は「致命傷の即検知」だけ)。

### TypeScript example
```ts
import { describe, it, expect } from "vitest";

const BASE = process.env.SYSTEM_URL ?? "http://localhost:8080";

// 起動の生死だけを数秒で確認する最小集合
describe("smoke", () => {
  it("ヘルスチェックが 200 を返す", async () => {
    const res = await fetch(`${BASE}/health`);
    expect(res.status).toBe(200);
  });
});
```

### 落とし穴
あれもこれもと項目を足すとスモークでなくなり、足切りの速さという利点を失う。
逆に health だけ見て主要機能の 1 経路を入れないと、起動はするが壊れている状態を通す。

## サニティテスト

### 概要
特定の修正や小変更が意図どおり効いているかを、狭い範囲で素早く確認する。

### 目的/いつ使う
バグ修正後や小さな変更後に、その箇所と周辺だけを軽く確かめたいときに使う。
全体の健全性確認には使わない(それはスモークや回帰の役割)。

### TypeScript example
```ts
import { describe, it, expect } from "vitest";
import { parseAmount } from "./parse-amount";

// 直前の修正点(全角数字の許容)に絞って確認する
describe("sanity: parseAmount 全角対応", () => {
  it("全角数字を半角として解釈する", () => {
    expect(parseAmount("１２３")).toBe(123);
  });
});
```

### 落とし穴
スモークとの線引きが曖昧になりやすい。スモークは「広く浅く起動確認」、サニティは「狭く深く変更確認」と役割で分ける。
サニティで通ったから全体も大丈夫、と早合点して回帰を省くと別の箇所の退行を見逃す。

## 回帰テスト

### 概要
変更によって既存の動作が壊れていないかを、過去に通ったテスト群を再実行して確認する。

### 目的/いつ使う
コード変更・依存更新・リファクタのたびに、CI で継続的に走らせる。
新機能そのものの検証には使わない(回帰は「壊していないこと」の保証)。

### TypeScript example
```ts
import { describe, it, expect } from "vitest";
import { renderInvoice } from "./invoice";

// 過去に修正したバグを再発防止として固定する(バグ番号を残すと由来が追える)
describe("回帰", () => {
  it("#482: 数量 0 の行で NaN を出さない", () => {
    const out = renderInvoice([{ name: "X", qty: 0, price: 100 }]);
    expect(out).not.toContain("NaN");
  });
});
```

### 落とし穴
落ちたテストを直さず skip で黙らせると、回帰スイートは飾りになる。
過去バグの再現テストを残さないと、同じ欠陥が何度でも戻ってくる。修正のたびに 1 本固定する。

## 補足: テストピラミッド vs テストトロフィー(配分論)

どのレベルに何本書くかの配分を示す 2 つのモデル。どちらも「遅く脆いテストを上に積みすぎるな」が共通の主張で、重心の置き方が違う。

テストピラミッド(Mike Cohn)は、土台に速い単体テストを多く、上に行くほど結合・E2E を少なく積む。
実行が速く失敗箇所を切り分けやすいが、モックに頼りすぎると「単体は全部緑なのに繋ぐと壊れる」状態を招きうる。

テストトロフィー(Kent C. Dodds)は、結合テストに最も重みを置く。
「ユーザーの使い方に近いほど確信度が高い」という主張で、実依存をなるべく本物にした結合層を厚くする。
ただし結合を厚くするほど 1 本が遅く不安定になりやすく、土台の静的検査(型・lint)で下支えする前提が要る。

実務上の指針はひとつ。本数ではなく、各テストが「壊れたら本当に困ること」を検証しているかで配分を決める。
速くて安定なものを多く、遅くて脆いものを少なく。これはどちらのモデルとも矛盾しない。
