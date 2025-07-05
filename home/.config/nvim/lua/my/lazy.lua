local mylazy = {}

function mylazy.setup()
  -- Install package manager
  --    https://github.com/folke/lazy.nvim
  --    `:help lazy.nvim.txt` for more info
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end

  vim.opt.rtp:prepend(lazypath)

  local opts = { defaults = { lazy = false }, performance = { cache = { enabled = true } } }

  -- Any lua file in ~/.config/nvim/lua/plugins/*.lua will be automatically merged in the main plugin spec
  -- require('lazy').setup('plugins', opts)
  require("lazy").setup({
    "neovim/nvim-lspconfig",
    "scrooloose/nerdcommenter",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/vim-vsnip",
    "obaland/vfiler.vim",
    "machakann/vim-highlightedyank",
    "kamykn/spelunker.vim",
    "mhinz/vim-startify",
    "bluz71/vim-nightfly-guicolors",
    "marko-cerovac/material.nvim",
    "ConradIrwin/vim-bracketed-paste",
    "kana/vim-smartinput",
    "airblade/vim-gitgutter",
    "tpope/vim-fugitive",
    "scrooloose/vim-slumlord",
    "thinca/vim-quickrun",
    "haya14busa/vim-edgemotion",
    "kana/vim-smartword",
    "tani/dmacro.vim",
    "hashivim/vim-terraform",
    "rachartier/tiny-inline-diagnostic.nvim",
    "rachartier/tiny-code-action.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "github/copilot.vim",
    "vim-denops/denops.vim",
    "folke/tokyonight.nvim",
  }, opts)
end

return mylazy
