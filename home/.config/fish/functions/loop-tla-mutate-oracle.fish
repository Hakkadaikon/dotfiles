function loop-tla-mutate-oracle --description 'Run the TLA+ mutation oracle on a spec'
    python3 "$LOOPENG_HOME/bin/tla_mutate_oracle.py" $argv
end
