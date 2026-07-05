# keychain manages one long-lived ssh-agent per machine and shares it across
# shells/tmux panes/reboots. Without it, SSH_AUTH_SOCK only lives in the shell
# that ran `ssh-add`, so every new pane loses the agent and every reboot loses
# the loaded key.
if status is-interactive; and command -v keychain >/dev/null
    keychain --quiet --eval --shell fish id_25519_git | source
end
