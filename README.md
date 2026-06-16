# Dotfiles
## Overview
Build my castle quickly.

## related plugin
* https://github.com/folke/lazy.nvim

## Usage
### Install dependencies
Tools (neovim, wezterm, stylua, shfmt) are installed via Nix from `flake.nix`.
The first run installs Nix itself with the
[Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer);
open a new shell afterward and run it again to install the tools.
```shell
./env.sh install
```

### Setup
```shell
./env.sh setup
```

### Register MCP servers
```shell
./env.sh mcp
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

- **Linux / WSL**: requires `bwrap` (bubblewrap) and `socat`.
  ```shell
  sudo apt install bubblewrap socat
  ```
- **macOS**: uses the built-in Seatbelt (`sandbox-exec`); no install needed.
