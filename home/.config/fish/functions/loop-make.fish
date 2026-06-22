function loop-make --description 'Run a loopeng Makefile target in the current dir'
    # Shared helper; loop-outer/middle/inner autoload from their own files.
    make -f "$LOOPENG_HOME/Makefile.loopeng" $argv
end
