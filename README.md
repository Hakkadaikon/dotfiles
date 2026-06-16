# Dotfiles
## Overview
Build my castle quickly.

## Version
nvim : v0.7.0-dev

## related plugin
* https://github.com/junegunn/vim-plug
* https://github.com/MichaelMure/mdr

## Usage
### Install dependencies
```shell
./env.sh install 
```

### Setup
```shell
./env.sh setup
```

### Cleanup 
```shell
./env.sh cleanup 
```

### Check
```shell
./env.sh check
```

## Claude Code
`home/.claude/settings.json` enables the bash sandbox with `failIfUnavailable: true`.
This requires `bwrap` (bubblewrap); without it Claude Code fails to start.

```shell
sudo apt install bubblewrap
```
