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
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import ./config/nvim.nix)
        ];
      };
    in
    {
      packages = {
        default = pkgs.neovim;
        neovim = pkgs.neovim;
      };

      devShells.default = pkgs.mkShell {
        buildInputs = [ pkgs.neovim ];
      };
    }
  );
}
