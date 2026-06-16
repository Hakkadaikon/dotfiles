if status is-interactive
    # Interactive-only setup goes here.
    # PATH and nix tooling are handled by conf.d/nix-profile.fish and
    # Determinate's /etc/fish/conf.d/nix.fish. Plugins (z, bobthefish) come
    # from the nix profile's share/fish/vendor_*.d, loaded automatically.

    # bobthefish: never show user@host in the prompt.
    set -g theme_display_user no
end
