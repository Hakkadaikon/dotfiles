function loop-tla-mutate-oracle --description 'Run the TLA+ mutation oracle on a spec'
    # tla_mutate_oracle.py is on PATH from the hymme skill-tools profile entry.
    tla_mutate_oracle.py $argv
end
