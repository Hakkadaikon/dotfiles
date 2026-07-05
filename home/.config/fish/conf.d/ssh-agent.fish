# keychain manages one long-lived ssh-agent per machine and shares it across
# shells/tmux panes/reboots. Without it, SSH_AUTH_SOCK only lives in the shell
# that ran `ssh-add`, so every new pane loses the agent and every reboot loses
# the loaded key.
if status is-interactive; and command -v keychain >/dev/null
    # keychain 2.9.8 has no fish output mode; it picks Bourne vs C-shell via
    # $SHELL. Force Bourne output, then translate its `FOO=bar; export FOO;`
    # lines into fish's `set -gx FOO bar`.
    SHELL=/bin/sh keychain --quiet id_25519_git
    set -l dump "$HOME/.keychain/"(hostname)"-sh"
    if test -f "$dump"
        set -l pairs (string match -rg '^(\w+)=(.*); export \1;$' <"$dump")
        for i in (seq 1 2 (count $pairs))
            set -gx $pairs[$i] $pairs[(math $i + 1)]
        end
    end
end
