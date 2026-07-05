# Start one ssh-agent per login and share it across shells/tmux panes by
# caching its env vars in a file. Without this, SSH_AUTH_SOCK only lives in
# the shell that ran `ssh-add`, so every new pane/tmux window loses the agent.
if status is-interactive
    set -l agent_env "$HOME/.ssh/agent.fish.env"

    if test -f "$agent_env"
        source "$agent_env"
    end

    if not test -n "$SSH_AUTH_SOCK"; or not kill -0 "$SSH_AGENT_PID" 2>/dev/null
        ssh-agent -c | grep -v '^echo' > "$agent_env"
        source "$agent_env"
    end
end
