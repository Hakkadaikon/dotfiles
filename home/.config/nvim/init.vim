"#############################################################################"
"# File        : init.vim                                                     "
"# Description : Files loaded when nvim starts.                               "
"# Remarks     :                                                              "
"#############################################################################"

"#############################################################################"
" Plugins                                                                     "
"#############################################################################"
call plug#begin()
"Auto completes"
Plug 'neovim/nvim-lspconfig'             "LSP config"
Plug 'scrooloose/nerdcommenter'          ""
Plug 'williamboman/mason.nvim'           ""
Plug 'williamboman/mason-lspconfig.nvim' ""
Plug 'hrsh7th/nvim-cmp'                  "Auto complete"
Plug 'hrsh7th/cmp-nvim-lsp'              "Auto complete"
Plug 'hrsh7th/vim-vsnip'                 "Auto complete"

"Filers"
Plug 'obaland/vfiler.vim'                "Filer"

"Views"
Plug 'machakann/vim-highlightedyank'     "Highlight the yanked string"
Plug 'nvim-lualine/lualine.nvim'         "Extended status bar"
Plug 'kamykn/spelunker.vim'              "Spell check"

"Color schemas"
Plug 'mhinz/vim-startify'                "Show start screen when starting vim"
"Plug 'w0ng/vim-hybrid'"                 "Schema for vim (hybrid)"
Plug 'bluz71/vim-nightfly-guicolors'
Plug 'marko-cerovac/material.nvim'       "Schema for neovim (material)"

"Input plugins"
Plug 'ConradIrwin/vim-bracketed-paste'   "Automatically change paste mode"
Plug 'kana/vim-smartinput'

"Git plugins"
Plug 'airblade/vim-gitgutter'            "Show git diffs"
Plug 'tpope/vim-fugitive'                "Operate git from vim"

"External application cooperation"
Plug 'scrooloose/vim-slumlord'           "Edit PlantUML"
"Plug 'skanehira/preview-markdown.vim'"  "Preview markdown"
Plug 'thinca/vim-quickrun'               ""
Plug 'haya14busa/vim-edgemotion'         ""
Plug 'kana/vim-smartword'                ""
Plug 'tani/dmacro.vim'                   ""

"Fuzzy finder"
Plug 'vim-denops/denops.vim'             ""
Plug 'vim-fall/fall.vim'                 ""
call plug#end()

"#############################################################################"
" Plugin settings                                                             "
"#############################################################################"
let g:enable_spelunker_vim = 1

"lsp settings"
"------------------------------------------------------------------------------"
"let lsp_log_verbose=1"
"let lsp_log_file= expand('~/lsp.log')"
"------------------------------------------------------------------------------"

"phpactor settings"
"------------------------------------------------------------------------------"
"nmap <silent> ww :call phpactor#Hover()<CR>"
"-----------------------------------------------------------------------------"

"clipboard settings(windows only)"
"-----------------------------------------------------------------------------"
source <sfile>:h/lib/osc52.vim
augroup osc52
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call SendViaOSC52(getreg(v:event.regname)) | endif
augroup END

"set tags=~/repos/fork/vim/src/tags"

lua << EOF
require('my/common').setup()
require('my/colorscheme').setup()
require('my/lsp').setup()
require('my/keymap').setup()
require('my/tabstop').setup()
EOF
