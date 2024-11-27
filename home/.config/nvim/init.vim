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

"Search plugins"
Plug 'ctrlpvim/ctrlp.vim'                "Search for files with [Ctrl + p]"
Plug 'mattn/ctrlp-lsp'                   "Jump the source code definition with [Ctrl + p]"

"External application cooperation"
Plug 'scrooloose/vim-slumlord'           "Edit PlantUML"
"Plug 'skanehira/preview-markdown.vim'   "Preview markdown"
Plug 'thinca/vim-quickrun'               ""
Plug 'haya14busa/vim-edgemotion'         ""
Plug 'kana/vim-smartword'                ""
Plug 'tani/dmacro.vim'                   ""
call plug#end()

"#############################################################################"
" Plugin settings                                                             "
"#############################################################################"
let g:enable_spelunker_vim = 1

"quickrun settings"
"-----------------------------------------------------------------------------"
"let g:quickrun_config['cpp/snip'] = {
"    \ 'command'       : 'g++',
"    \ 'exec'          : '%c %o -o %n -lgtest -lgtest_main -lpthread && ./%n',
"    \ 'outputter'     : 'message',
"    \ 'hook/snipe/enable' : 1,
"    \ 'hook/snipe/prefix' : '#include <cstdio>\nint main() {\n',
"    \ 'hook/snipe/suffix' : '\nreturn 0;\n}',
"    \ }
"------------------------------------------------------------------------------"

"lualine settings"
"-----------------------------------------------------------------------------"
lua << EOF
require('lualine').setup {
  options = {
    theme = 'material'
  }
}
EOF
"-----------------------------------------------------------------------------"

colorscheme material
highlight LineNr guifg=#00AFFF guibg=NONE
highlight CursorLineNr guifg=#FFFF00 guibg=NONE

"lsp settings"
"------------------------------------------------------------------------------"
"let lsp_log_verbose=1"
"let lsp_log_file= expand('~/lsp.log')"
"------------------------------------------------------------------------------"

"phpactor settings"
"------------------------------------------------------------------------------"
"nmap <silent> ww :call phpactor#Hover()<CR>"
"-----------------------------------------------------------------------------"

"##############################################################################"
" Common settings                                                              "
"##############################################################################"

"Search settings"
"-----------------------------------------------------------------------------"
set ignorecase     "Case insensitive"
set wrapscan       "Wrap around when the search is finished"
set incsearch      "Incremental search"
set hlsearch       "Highlight search results"
"-----------------------------------------------------------------------------"

"View settings"
"-----------------------------------------------------------------------------"
set number                     "Show line number"
set relativenumber             "Show relative line number"
:highlight LineNr ctermfg=239

set showcmd                    "Show the command your are typing"
set list                       "Show control characters"
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set cursorline                 "Highlight selected line"
set noswapfile                 "Dont create swap file"
"set nofoldenable"             "Dont fold the source code"
set autochdir                  "Change to the directory of open files"
set softtabstop=4              "Number of spaces for tab"
set shiftwidth=4               "Number of spaces for smart indent, command"
set cmdheight=2                "Number of lines the message display field"
set laststatus=2               "Always show status line"
set display=lastline           "Dont omit the characters displayed on the status line"
set showmatch matchtime=1      "Bracket highlighting"
set termguicolors
"-----------------------------------------------------------------------------"

"Other setting"
"-----------------------------------------------------------------------------"
set noerrorbells               "Beep suppression at the time of error"
set history=10000              "Number of saved vim command execution histories"
set clipboard&                 "Copy and paste between vim and other applications"
set clipboard^=unnamedplus
"-----------------------------------------------------------------------------"

"clipboard settings(windows only)"
"-----------------------------------------------------------------------------"
source <sfile>:h/lib/osc52.vim
augroup osc52
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call SendViaOSC52(getreg(v:event.regname)) | endif
augroup END

set tags=~/repos/fork/vim/src/tags
"-----------------------------------------------------------------------------"

"lsp settings"
source <sfile>:h/lib/lsp.lua

"Key bindings"
source <sfile>:h/lib/keymap.lua

"Tabstop"
source <sfile>:h/lib/tabstop.lua

"##############################################################################"
