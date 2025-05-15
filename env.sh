#!/bin/bash

MYNAME=$0
DOTFILES_DIR=${PWD}
DOTFILES_HOME_DIR=${DOTFILES_DIR}/home
HOME_DIR=~
NVIM_CONFIG_DIR=.config/nvim
OS=$(uname -s)

FILES=(
    ".tmux.conf"
    ".vimrc"
    "${NVIM_CONFIG_DIR}/init.vim"
    "${NVIM_CONFIG_DIR}/lib"
    "${NVIM_CONFIG_DIR}/lua"
    ".config/alacritty/alacritty.toml"
)

function usage() {
  echo "usage : ${MYNAME} [cleanup|setup|check]"
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
    brew install luarocks shfmt
    luarocks install --local --server=http://luarocks.org/dev luaformatter
  elif [[ "{$OS}" == "Linux" ]]; then
    # Support Ubuntu/Debian
    sudo apt update
    sudo apt install -y luarocks shfmt
    luarocks install --local --server=http://luarocks.org/dev luaformatter
  else
    echo "Unsupported OS: ${OS}"
    exit 1
  fi
}

function setup() {
  for FILE in "${FILES[@]}" ; do
    SRC_FILE=${DOTFILES_HOME_DIR}/${FILE}
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
