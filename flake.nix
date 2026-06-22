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

      # Loop engineering: TLA+ (TLC/SANY) and Apalache. nixpkgs has no official
      # package, so we fetch the release artifacts and wrap them with a JRE.
      # Versions/hashes pinned via nix-prefetch-url; bump both together.
      tla2tools = pkgs.fetchurl {
        url = "https://github.com/tlaplus/tlaplus/releases/download/v1.8.0/tla2tools.jar";
        hash = "sha256-I3Myvcx5o1x9Ju+nuCx3yFwnRFkcVZhnOopFCF/ypPs=";
      };
      tlaplus = pkgs.runCommand "tlaplus-1.8.0" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir -p $out/share/tlaplus $out/bin
        cp ${tla2tools} $out/share/tlaplus/tla2tools.jar
        makeWrapper ${pkgs.jdk}/bin/java $out/bin/tlc \
          --add-flags "-cp $out/share/tlaplus/tla2tools.jar tlc2.TLC"
        makeWrapper ${pkgs.jdk}/bin/java $out/bin/sany \
          --add-flags "-cp $out/share/tlaplus/tla2tools.jar tla2sany.SANY"
      '';

      apalacheSrc = pkgs.fetchurl {
        url = "https://github.com/apalache-mc/apalache/releases/download/v0.47.2/apalache-0.47.2.tgz";
        hash = "sha256-3i6K5MuzjXS9Mpy3fmQzKJ8qFJ0ebSy8UQVajKgLL7Q=";
      };
      apalache = pkgs.runCommand "apalache-0.47.2" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir -p $out
        tar xzf ${apalacheSrc} -C $out --strip-components=1
        # The shipped bin/apalache-mc launcher needs a JRE on PATH and JAVA_HOME.
        wrapProgram $out/bin/apalache-mc \
          --prefix PATH : ${pkgs.jdk}/bin \
          --set JAVA_HOME ${pkgs.jdk}
      '';

      loopeng = [
        tlaplus
        apalache
        pkgs.gnumake
        pkgs.python3 # runs the loop oracles (mutate / trace->gherkin)
        # ponytail: doorstop isn't in nixpkgs; install via `uv pip install doorstop`
        # when requirement traceability is actually needed. python3 alone runs the loop.
      ];

      tools = [
        pkgs.neovim
        pkgs.wezterm
        pkgs.stylua
        pkgs.shfmt
        pkgs.fish
        pkgs.fishPlugins.z
        pkgs.fishPlugins.bobthefish
        pkgs.elan # formal verification: Lean 4 toolchain manager (lake + lean)
      ] ++ loopeng;
    in
    {
      packages = {
        default = pkgs.neovim;
        neovim = pkgs.neovim;
        inherit tlaplus apalache;
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
