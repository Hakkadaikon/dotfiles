final: prev: {
  neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (oldAttrs: {
    version = "0.11.5";

    src = prev.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "v0.11.5";
      hash = "sha256-OsvLB9kynCbQ8PDQ2VQ+L56iy7pZ0ZP69J2cEG8Ad8A="; 
    };
  });
}
