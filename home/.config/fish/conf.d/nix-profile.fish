# Put `nix profile` user binaries ahead of system ones.
# Determinate's hook only adds the default profile, not ~/.nix-profile/bin.
if test -d "$HOME/.nix-profile/bin"
    fish_add_path --prepend --global "$HOME/.nix-profile/bin"
end
