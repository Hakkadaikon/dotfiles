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
`home/.claude/settings.json` enables the bash sandbox with `failIfUnavailable: true`,
so Claude Code fails to start if the sandbox backend is unavailable.

- **Linux / WSL**: requires `bwrap` (bubblewrap).
  ```shell
  sudo apt install bubblewrap
  ```
- **macOS**: uses the built-in Seatbelt (`sandbox-exec`); no install needed.
