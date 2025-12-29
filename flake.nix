{
  description = "hakkadaikon dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        nvimVersion = "0.11.5";
        nvimHash = "sha256-OsvLB9kynCbQ8PDQ2VQ+L56iy7pZ0ZP69J2cEG8Ad8A="; 

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (oldAttrs: {
                version = nvimVersion;
                src = prev.fetchFromGitHub {
                  owner = "neovim";
                  repo = "neovim";
                  rev = "v${nvimVersion}";
                  hash = nvimHash;
                };
              });
            })
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
