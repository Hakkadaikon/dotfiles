function loop-make --description 'Run a loopeng Makefile target in the current dir'
    # Thin wrapper so `loop-outer`/`loop-middle`/`loop-inner` need no -f flag.
    make -f "$LOOPENG_HOME/Makefile.loopeng" $argv
end

function loop-outer --description 'Scaffold a TLA+ spec + Gherkin feature (SPEC=Name)'
    loop-make loop-outer $argv
end

function loop-middle --description 'Model-check then mutation-test the spec (SPEC=Name)'
    loop-make loop-middle $argv
end

function loop-inner --description 'Replay a TLC counterexample as a Gherkin scenario (SPEC=Name)'
    loop-make loop-inner $argv
end

function loop-tla-mutate-oracle --description 'Run the TLA+ mutation oracle on a spec'
    python3 "$LOOPENG_HOME/bin/tla_mutate_oracle.py" $argv
end
