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

### Config evals
`evals/claude/` holds headless evals for this Claude Code setup and the hymme / superpowers plugins.
They score routing (did the right skill fire), end-to-end tasks against hidden tests, and planted review bugs, and record tokens per run.
Change one thing at a time and keep it only if quality holds and tokens drop; see `evals/claude/README.md`.
