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
Plug 'w0ng/vim-hybrid'                   "Schema for vim    (hybrid)"
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

"lspconfig settings"
"-----------------------------------------------------------------------------"
lua << EOF
require'lspconfig'.ts_ls.setup{
}
-- require'lspconfig'.rust_analyzer.setup{
-- }
-- require'lspconfig'.gopls.setup{
-- }
-- require'lspconfig'.clangd.setup{
-- }
require'lspconfig'.intelephense.setup{
    settings = {
        intelephense = {
            environment = {
                phpVersion = "8.2"
            }
        }
    }
}
EOF
"-----------------------------------------------------------------------------"

"LSP Sever management"
"-----------------------------------------------------------------------------"
lua << EOF
require('mason').setup{}
require('mason-lspconfig').setup_handlers(
    {
        function(server)
            local opt = {
              capabilities = require('cmp_nvim_lsp').default_capabilities(
                vim.lsp.protocol.make_client_capabilities()
              )
            }
            require('lspconfig')[server].setup(opt)
        end
    }
)
EOF
"-----------------------------------------------------------------------------"

"LSP handlers"
"-----------------------------------------------------------------------------"
lua << EOF
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    -- virtual_text = false
    virtual_text = {
      format = function(diagnostic)
      return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
      end,
    }
  }
)
EOF
"-----------------------------------------------------------------------------"

"-----------------------------------------------------------------------------"
lua << EOF
vim.cmd [[
set updatetime=500
highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
augroup lsp_document_highlight
  autocmd!
  " autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
  " autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
augroup END
]]
EOF
"-----------------------------------------------------------------------------"

"completion (hrsh7th/nvim-cmp)"
"-----------------------------------------------------------------------------"
lua << EOF
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    -- { name = "buffer" },
    -- { name = "path" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ['<C-l>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm { select = true },
  }),
  experimental = {
    ghost_text = true,
  },
})
EOF
"-----------------------------------------------------------------------------"

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

colorscheme hybrid

" vfiler.vim settings"
"-----------------------------------------------------------------------------"
"Execute explorer style."
function! s:start_explorer() abort
lua <<EOF

local configs = {
  options = {
    auto_cd     = true,
    auto_resize = true,
    keep        = true,
    name        = 'explorer',
    layout      = 'left',
    width       = 40,
    columns     = 'indent,name,mode,size',
  },
}

local path = vim.fn.bufname(vim.fn.bufnr())
if vim.fn.isdirectory(path) ~= 1 then
  path = vim.fn.getcwd()
end
path = vim.fn.fnamemodify(path, ':p:h')

require'vfiler'.start(path, configs)

EOF
endfunction
"------------------------------------------------------------------------------"

"vim-lsp settings"
"------------------------------------------------------------------------------"
"let lsp_log_verbose                 =1"
"let lsp_log_file                    = expand('~/lsp.log')"
let g:asyncomplete_remove_duplicates = 1
let g:lsp_diagnostics_enabled        = 1
let g:lsp_text_edit_enabled          = 1
let g:asyncomplete_auto_completeopt  = 1
let g:asyncomplete_smart_completion  = 1
let g:asyncomplete_auto_popup        = 1
let g:lsp_diagnostics_echo_cursor    = 1
let g:asyncomplete_popup_delay       = 0

nmap <silent> <C-]> :LspDefinition<CR> "Jump definition"
nmap <silent> gd    :LspDefinition<CR> "Jump definition"
nmap <silent> gD    :LspReferences<CR> "View caller"
"------------------------------------------------------------------------------"

"phpactor settings"
"------------------------------------------------------------------------------"
"nmap <silent> ww :call phpactor#Hover()<CR>"
""-----------------------------------------------------------------------------"

"------------------------------------------------------------------------------"

"##############################################################################"
" Common settings                                                              "
"##############################################################################"

" Search settings
"-----------------------------------------------------------------------------"
set ignorecase     "Case insensitive"
set wrapscan       "Wrap around when the search is finished"
set incsearch      "Incremental search"
set hlsearch       "Highlight search results"
nnoremap <ESC> :nohlsearch<CR>
                   "Remove highlighting with [ESC] key"
"-----------------------------------------------------------------------------"

"View settings"
"-----------------------------------------------------------------------------"
set number                     "Show line number"
set showcmd                    "Show the command your are typing"
set list                       "Show control characters"
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%"
"set cursorline                "Highlight selected line"
set expandtab                  "Replace tab with a half-width space"
set noswapfile                 "Don't create swap file"
"set nofoldenable              "Don't fold the source code"
set autochdir                  "Change to the directory of open files"
set softtabstop=4              "Number of spaces for tab"
set shiftwidth=4               "Number of spaces for smart indent, command"
set cmdheight=2                "Number of lines the message display field"
set laststatus=2               "Always show status line"
set display=lastline           "Don't omit the characters displayed on the status line"
set showmatch matchtime=1      "Bracket highlighting"
set termguicolors
"-----------------------------------------------------------------------------"

" Syntax settings by extension
"-----------------------------------------------------------------------------"
autocmd BufNewFile,BufRead init.vim set filetype=vim
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
" Key bind                                                                    "
"-----------------------------------------------------------------------------"
"lsp key bind"
lua << EOF
vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
EOF

map <C-j> <Plug>(edgemotion-j)
map <C-k> <Plug>(edgemotion-k)

inoremap <C-y> <Plug>(dmacro-play-macro)

nnoremap tt :QuickRun<CR>
nnoremap sa :Startify<CR>
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
nnoremap <C-y> <Plug>(dmacro-play-macro)
nnoremap <ESC> :nohlsearch<CR> "Remove highlighting with [ESC] key"

noremap <silent><C-e> :call <SID>start_explorer()<CR> "VFiler"
"-----------------------------------------------------------------------------"

"##############################################################################"
