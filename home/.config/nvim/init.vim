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

"clipboard settings(windows only)"
"-----------------------------------------------------------------------------"
source <sfile>:h/lib/osc52.vim
augroup osc52
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call SendViaOSC52(getreg(v:event.regname)) | endif
augroup END

"set tags=~/repos/fork/vim/src/tags"
