"#############################################################################"
"# File        : init.vim                                                     "
"# Description : Files loaded when nvim starts.                               "
"# Remarks     :                                                              "
"#############################################################################"

"#############################################################################"
" Plugins                                                                     "
"#############################################################################"
lua << EOF
require('my/lazy').setup()
require('my/common').setup()
require('my/colorscheme').setup()
require('my/lsp').setup()
require('my/keymap').setup()
require('my/tabstop').setup()
EOF

let g:enable_spelunker_vim = 1

" let g:quickrun_config = {}
" let g:quickrun_config.c = {
" \   'command': 'gcc',
" \   'cmdopt': '-W -Wextra -O2 -fstack-usage',
" \   'exec': [
" \       '%c %o %s -o %s:p:r',
" \       '%s:p:r',
" \       'echo ---------- stack usage ----------',
" \       'cat %s:p:r.su',
" \       'echo ---------------------------------',
" \       'rm -f %s:p:r.su',
" \   ],
" \   'tempfile': '%{tempname()}.c',
" \   'hook/sweep/files': ['%S:p:r']
" \}

" let g:quickrun_config = {}
" let g:quickrun_config.c = {
" \   'command': 'gcc',
" \   'cmdopt': '-W -Wextra -O3 -fstack-usage',
" \   'exec': [
" \       '%c %o %s -o %s:p:r',
" \       'valgrind --tool=callgrind --instr-atstart=no %s:p:r',
" \       'echo ---------- gcc stack usage ----------',
" \       'cat %s:p:r.su',
" \       'echo -------------------------------------',
" \       'callgrind_annotate callgrind.out.*',
" \       'rm -f %s:p:r.su callgrind.out.*',
" \   ],
" \}

"clipboard settings(windows only)"
source <sfile>:h/lib/osc52.vim
augroup osc52
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call SendViaOSC52(getreg(v:event.regname)) | endif
augroup END

"set tags=~/repos/fork/vim/src/tags"
