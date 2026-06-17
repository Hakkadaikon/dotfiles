# uv が生成する PATH 設定。未インストール環境では無いので存在時だけ source。
if test -f "$HOME/.local/bin/env.fish"
    source "$HOME/.local/bin/env.fish"
end
