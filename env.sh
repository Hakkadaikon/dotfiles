#!/bin/bash

MYNAME=$0
DOTFILES_DIR=${PWD}
DOTFILES_HOME_DIR=${DOTFILES_DIR}/home
HOME_DIR=~
CONFIG_DIR=.config
OS=$(uname -s)

FILES=(
  ".tmux.conf"
  ".vimrc"
  "${CONFIG_DIR}/nvim/init.lua"
  "${CONFIG_DIR}/nvim/lua"
  "${CONFIG_DIR}/wezterm/wezterm.lua"
  "${CONFIG_DIR}/fish/config.fish"
  "${CONFIG_DIR}/fish/conf.d/nix-profile.fish"
  "${CONFIG_DIR}/fish/conf.d/rustup.fish"
  "${CONFIG_DIR}/fish/conf.d/uv.env.fish"
  "${CONFIG_DIR}/fish/conf.d/loopeng.fish"
  "${CONFIG_DIR}/fish/functions"
  "${CONFIG_DIR}/loopeng"
  ".claude/settings.json"
  ".claude/statusline.sh"
  ".claude/CLAUDE.md"
  ".claude/skills"
  ".claude/commands"
  ".claude/agents"
  ".claude/rules"
  ".claude/hooks"
  ".claude/workflows"
)

function usage() {
  echo "usage : ${MYNAME} [install|cleanup|setup|mcp|check]"
  echo "  install : install dependencies"
  echo "  cleanup : remove symlinks"
  echo "  setup   : create symlinks"
  echo "  mcp     : register user-scope MCP servers"
  echo "  check   : check symlinks"
}

function echowarn() {
  STR=$1
  echo -e "\e[30;43m${STR}\e[m"
}

function echoerr() {
  STR=$1
  echo -e "\e[37;41m${STR}\e[m"
}

function install() {
  # Install Nix (Determinate Systems installer) if missing, then install all
  # tools (neovim/wezterm/stylua/shfmt) from flake.nix into the user profile.
  if ! command -v nix >/dev/null 2>&1; then
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
    # installer が書く profile スクリプトを source し、新シェルなしで継続する。
    NIX_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    [ -e "${NIX_PROFILE}" ] && . "${NIX_PROFILE}"
  fi
  # Upgrade by profile-entry Name if present, add otherwise. Idempotent.
  # --refresh on both bypasses Nix's cached github flake rev (e.g. a pre-push one).
  #   $1 = profile Name, $2 = add ref, $3.. = extra add flags
  _profile_ensure() {
    # `nix profile list` colorizes the Name even without a TTY; strip ANSI first.
    if nix profile list 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' \
       | grep -qE "^Name:[[:space:]]+$1\$"; then
      nix profile upgrade --refresh "$1"
    else
      nix profile add "${@:2}"
    fi
  }
  # Migrate older installs: hymme used to publish its bundle as `tools` too, which
  # collided with dotfiles' `tools` by name. If a profile entry named `tools` is
  # sourced from hymme (not dotfiles), drop it so the rename to `skill-tools` below
  # installs cleanly. awk reads the entry as a block (Name .. URL on separate lines).
  if nix profile list 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk '
      /^Name:/            { name=$2 }
      /^Original flake URL:/ { if (name=="tools" && $0 ~ /Hakkadaikon\/hymme/) found=1 }
      END { if (found) exit 0; else exit 1 }'; then
    nix profile remove tools 2>/dev/null || true
  fi
  # dotfiles tools (neovim/wezterm/stylua/shfmt/fish); profile Name: tools.
  _profile_ensure tools "${DOTFILES_DIR}#tools"
  # Skill toolchain (TLA+/Apalache/make/python3/Lean) lives in the hymme plugin's
  # flake so the loop-engineering / test-design / formal-verification skills find
  # their tools on PATH; profile Name: skill-tools. python3 collides with dotfiles'
  # transitive python3, so give hymme lower priority (higher number) to defer the
  # shared file. profile add/upgrade's own --refresh only bypasses the derivation
  # cache, not the flake input's cached rev, so force that separately first.
  nix flake prefetch --refresh github:Hakkadaikon/hymme >/dev/null
  _profile_ensure skill-tools "github:Hakkadaikon/hymme#skill-tools" --refresh --priority 6
  # Lean 4 本体は elan が別管理。hymme tools の elan で stable toolchain を入れる(冪等)。
  command -v elan >/dev/null 2>&1 && elan default stable
}

function setup() {
  for FILE in "${FILES[@]}"; do
    SRC_FILE=${DOTFILES_HOME_DIR}/${FILE}
    SRC_DIR=$(dirname "${SRC_FILE}")
    if [ ! -d "${SRC_DIR}" ]; then
      mkdir -p "${SRC_DIR}"
      echo "created directory: ${SRC_DIR}"
    fi

    DST_LINK=${HOME_DIR}/${FILE}
    mkdir -p "$(dirname "${DST_LINK}")"
    # A stale symlink (or a dir symlink left by an older FILES layout) makes
    # `ln -s` create the link *inside* it. Drop any existing symlink first; back
    # up a real file/dir so we never clobber user data silently.
    if [ -L "${DST_LINK}" ]; then
      rm -f "${DST_LINK}"
    elif [ -e "${DST_LINK}" ]; then
      mv "${DST_LINK}" "${DST_LINK}.bak.$$"
      echowarn "backed up existing ${DST_LINK} -> ${DST_LINK}.bak.$$"
    fi
    ln -s ${SRC_FILE} ${DST_LINK}
    echo "link [${SRC_FILE}] -> [${DST_LINK}]"
  done
}

function cleanup() {
  for FILE in "${FILES[@]}"; do
    DST_LINK=${HOME_DIR}/${FILE}
    unlink ${DST_LINK}
    echo "cleanup [${DST_LINK}]"
  done
}

function mcp() {
  # user スコープに MCP サーバーを登録する。~/.claude.json は dotfiles 管理外(可変)なので
  # 設定実体は home/.claude/mcp/*.mcp.json テンプレに置き、ここから add-json で流し込む。冪等。
  MCP_DIR="${DOTFILES_HOME_DIR}/.claude/mcp"
  for name in terraform aws; do
    SERVER_JSON=$(python3 -c "import json; d=json.load(open('${MCP_DIR}/${name}.mcp.json')); print(json.dumps(d['mcpServers']['${name}']))")
    claude mcp remove -s user "${name}" >/dev/null 2>&1
    claude mcp add-json -s user "${name}" "${SERVER_JSON}" && echo "mcp registered: ${name}"
  done
}

function check() {
  for FILE in "${FILES[@]}"; do
    DST_LINK=${HOME_DIR}/${FILE}

    echo -n "path [${DST_LINK}] : "
    if [ -e ${DST_LINK} ]; then
      echo "Found!"
    else
      echowarn "Not found!!!"
    fi
  done
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

case ${1} in
"install")
  install
  ;;
"cleanup")
  cleanup
  ;;
"setup")
  cleanup && setup
  ;;
"mcp")
  mcp
  ;;
"check")
  check
  ;;
*)
  usage
  ;;
esac
