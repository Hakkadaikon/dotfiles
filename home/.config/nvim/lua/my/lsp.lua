local mylsp = {}

function mylsp.setup()
  -- vim.lsp.set_log_level("off")

  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  local server_settings = {
    clangd = {
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
    },
    intelephense = {
      settings = {
        intelephense = {
          environment = {
            phpVersion = "8.2",
          },
        },
      },
    },
    denols = {
      root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
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
    },
  }

  require("mason").setup({})

  require("mason-lspconfig").setup({
    ensure_installed = {
      "rust_analyzer",
      "gopls",
      "vimls",
      "lua_ls",
      "jdtls",
      "terraformls",
      "clangd",
      "intelephense",
      "denols"
    },
    handlers = {
      function(server_name)
        local opts = {
          capabilities = capabilities,
        }

        if server_settings[server_name] then
          opts = vim.tbl_deep_extend("force", opts, server_settings[server_name])
        end

        require("lspconfig")[server_name].setup(opts)
      end,
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
