{
  description = "hakkadaikon dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
      pkgs = import nixpkgs { inherit system; };
      tools = [
        pkgs.neovim
        pkgs.wezterm
        pkgs.stylua
        pkgs.shfmt
        pkgs.fish
        pkgs.fishPlugins.z
        pkgs.fishPlugins.bobthefish
        pkgs.elan # formal verification: Lean 4 toolchain manager (lake + lean)
      ];
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
