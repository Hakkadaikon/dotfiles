local mylsp = {}

function mylsp.setup()
  vim.lsp.set_log_level("off")

  local lspconfig = require("lspconfig")

  lspconfig.rust_analyzer.setup({})

  lspconfig.gopls.setup({})

  lspconfig.vimls.setup({})

  lspconfig.lua_ls.setup({})

  lspconfig.jdtls.setup({})

  lspconfig.terraformls.setup({})

  lspconfig.clangd.setup({
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--completion-style=detailed",
    },
    settings = {
      clangd = {
        fallbackFlags = {
          -- "-std=c++17",
        },
      },
    },
  })

  lspconfig.intelephense.setup({
    settings = {
      intelephense = {
        environment = {
          phpVersion = "8.2",
        },
      },
    },
  })

  -- Mason
  require("mason").setup({})
  require("mason-lspconfig").setup_handlers({
    function(server)
      local opt = {
        capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
      }
      require("lspconfig")[server].setup(opt)
    end,
  })

  lspconfig.denols.setup({
    root_dir = lspconfig.util.root_pattern("deno.json"),
    init_options = {
      lint = true,
      unstable = true,
      suggest = {
        imports = {
          hosts = {
            ["https://deno.land"] = true,
            ["https://cdn.nest.land"] = true,
            ["https://crux.land"] = true,
          },
        },
      },
    },
  })

  vim.cmd([[
  set updatetime=500
  highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
  highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
  highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
  augroup lsp_document_highlight
    autocmd!
    "autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
    "autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
  augroup END
  ]])

  local cmp = require("cmp")
  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    sources = { { name = "nvim_lsp" }, { name = "buffer" }, { name = "path" } },
    mapping = cmp.mapping.preset.insert({
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-l>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    experimental = { ghost_text = true },
  })
end

return mylsp
