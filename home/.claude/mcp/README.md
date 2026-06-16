# MCP テンプレート

MCP サーバー設定のテンプレート置き場。`~/.claude/.mcp.json` は Claude Code に読まれない(公式が明記)。Claude Code が読むのは `<project>/.mcp.json` と `~/.claude.json`(user スコープ)だけ。

ここでは user スコープに入れる。`~/.claude.json` は可変ファイルで dotfiles 管理に向かないため、設定実体はこのテンプレに置き、`env.sh mcp` が `claude mcp add-json -s user` で流し込む(冪等)。

```sh
./env.sh mcp   # terraform / aws を user スコープに登録。全プロジェクトで有効
```

登録確認:

```sh
claude mcp list
```

## terraform (`terraform.mcp.json`)

- `hashicorp/terraform-mcp-server` を docker で起動。docker が必要。
- レジストリ/プロバイダ検索はトークン不要。HCP Terraform を操作するときだけ環境変数 `TFE_TOKEN`(必要なら `TFE_ADDRESS`)を設定する。

## aws (`aws.mcp.json`)

- `mcp-proxy-for-aws` を uvx で起動。`uv` が必要。
- 接続先エンドポイントは `us-east-1` 固定(AWS MCP サービスの受け口。リージョン別エンドポイントは無い)。
- `--skip-auth` 付き。AWS 認証情報が無くてもドキュメント検索などは動く。API 呼び出しにはローカルの認証情報が必要。
- 操作対象リージョンは `AWS_REGION` で指定(デフォルト `ap-northeast-1`)。東京のリソースはこれで扱える。

## `all.mcp.json`

terraform と aws をまとめた project スコープ用。特定リポだけで使いたいときにリポ直下へ `.mcp.json` としてコピーする(`settings.json` の `enableAllProjectMcpServers: true` で自動承認)。
