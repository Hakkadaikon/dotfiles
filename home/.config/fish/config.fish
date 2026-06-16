# Login shell is the system fish (/usr/bin/fish), which can't see the nix
# profile's bobthefish/z plugins. Re-exec into the nix fish on entry.
# Guard against a loop: only re-exec if we're not already the nix one.
set -l nix_fish "$HOME/.nix-profile/bin/fish"
if test -x "$nix_fish"; and test (status fish-path) != (path resolve "$nix_fish")
    exec "$nix_fish"
end

if status is-interactive
    # Interactive-only setup goes here.
    # PATH and nix tooling are handled by conf.d/nix-profile.fish and
    # Determinate's /etc/fish/conf.d/nix.fish. Plugins (z, bobthefish) come
    # from the nix profile's share/fish/vendor_*.d, loaded automatically.

    # bobthefish: never show user@host in the prompt.
    set -g theme_display_user no
end
