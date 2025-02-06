local mylsp = {}

function mylsp.setup()
  -- LSP Config
  local lspconfig = require('lspconfig')

  lspconfig.ts_ls.setup{
  }

  lspconfig.rust_analyzer.setup{
  }

  lspconfig.gopls.setup{
  }

  lspconfig.vimls.setup{
  }

  lspconfig.lua_ls.setup{
  }

  lspconfig.jdtls.setup{
  }

  lspconfig.clangd.setup{
    cmd = {
      "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed"
    },
    settings = {
      clangd = {
        fallbackFlags = { "-std=c++17" },
      }
    }
  }

  lspconfig.intelephense.setup{
    settings = {
      intelephense = {
        environment = {
            phpVersion = "8.2"
        }
      }
    }
  }

  -- Mason
  require('mason').setup{}
  require('mason-lspconfig').setup_handlers({
    function(server)
      local opt = {
        capabilities = require('cmp_nvim_lsp').default_capabilities(
          vim.lsp.protocol.make_client_capabilities()
        )
      }
      require('lspconfig')[server].setup(opt)
    end
  })

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
  vim.cmd([[
    autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focus=false })
  ]])

  vim.cmd [[
  set updatetime=500
  highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
  highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
  highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
  augroup lsp_document_highlight
    autocmd!
    "autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
    "autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
  augroup END
  ]]

  local cmp = require("cmp")
  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "buffer" },
      { name = "path" },
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
end

return mylsp
