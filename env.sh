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
  "${CONFIG_DIR}/fish/conf.d/nix-profile.fish"
  ".claude/settings.json"
  ".claude/statusline.sh"
  ".claude/CLAUDE.md"
  ".claude/skills"
  ".claude/commands"
  ".claude/agents"
  ".claude/rules"
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
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install
    echo "Nix installed. Open a new shell (or source the nix profile) and re-run: ${MYNAME} install"
    return
  fi
  nix profile add "${DOTFILES_DIR}#tools"
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
