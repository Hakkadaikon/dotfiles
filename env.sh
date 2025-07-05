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
  "${CONFIG_DIR}/nvim/init.vim"
  "${CONFIG_DIR}/nvim/lib"
  "${CONFIG_DIR}/nvim/lua"
  "${CONFIG_DIR}/wezterm/wezterm.lua"
)

function usage() {
  echo "usage : ${MYNAME} [install|cleanup|setup|check]"
  echo "  install : install dependencies"
  echo "  cleanup : remove symlinks"
  echo "  setup   : create symlinks"
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
  if [[ "${OS}" == "Darwin" ]]; then
    brew install stylua shfmt
    brew install --cask wezterm@nightly
  elif [[ "{$OS}" == "Linux" ]]; then
    # Support Ubuntu/Debian

    # Add WezTerm repository
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

    sudo apt update
    sudo apt install -y stylua shfmt wezterm@nightly
  else
    echo "Unsupported OS: ${OS}"
    exit 1
  fi
}

function setup() {
  for FILE in "${FILES[@]}" ; do
    SRC_FILE=${DOTFILES_HOME_DIR}/${FILE}
    SRC_DIR=$(dirname "${SRC_FILE}")
    if [ ! -d "${SRC_DIR}" ]; then
      mkdir -p "${SRC_DIR}"
      echo "created directory: ${SRC_DIR}"
    fi

    DST_LINK=${HOME_DIR}/${FILE}
    ln -s ${SRC_FILE} ${DST_LINK}
    echo "link [${SRC_FILE}] -> [${DST_LINK}]"
  done
}

function cleanup() {
  for FILE in "${FILES[@]}" ; do
    DST_LINK=${HOME_DIR}/${FILE}
    unlink ${DST_LINK}
    echo "cleanup [${DST_LINK}]"
  done
}

function check() {
  for FILE in "${FILES[@]}" ; do
    DST_LINK=${HOME_DIR}/${FILE}

    echo -n "path [${DST_LINK}] : "
    if [ -e ${DST_LINK} ]; then
      echo "Found!"
    else
      echowarn "Not found!!!"
    fi
  done
}

if [ $# -ne 1 ];then
    usage
    exit 1
fi

case ${1} in
  "install")
    install;;
  "cleanup")
    cleanup;;
  "setup")
    cleanup && setup;;
  "check")
    check;;
  *)
    usage;;
esac
