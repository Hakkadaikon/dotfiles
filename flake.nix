{
  description = "hakkadaikon dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:

  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        # context-mode is ELv2 (source-available, unfree to nixpkgs); allow only it.
        config.allowUnfreePredicate = pkg: pkgs.lib.getName pkg == "context-mode";
      };
      context-mode = pkgs.callPackage ./nix/context-mode { };

      # loop-engineering / test-design / formal-verification skills (and their
      # TLA+/Apalache/Lean toolchain) moved to the hymme repo's flake.
      # See github:Hakkadaikon/hymme.

      tools = [
        pkgs.neovim
        pkgs.wezterm
        pkgs.stylua
        pkgs.shfmt
        pkgs.nodejs
        pkgs.fish
        pkgs.fishPlugins.z
        pkgs.fishPlugins.bobthefish
        pkgs.socat
        pkgs.keychain
        context-mode
      ]
      # bubblewrap is Linux-only (namespaces); macOS sandboxing uses seatbelt.
      ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.bubblewrap ];
    in
    {
      packages = {
        default = pkgs.neovim;
        neovim = pkgs.neovim;
        # `nix profile install .#tools` installs everything env.sh used to apt/brew.
        tools = pkgs.buildEnv {
          name = "dotfiles-tools";
          paths = tools;
        };
      };

      devShells.default = pkgs.mkShell {
        buildInputs = tools;
      };
    }
  );
}
