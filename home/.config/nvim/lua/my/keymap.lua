local mykeymap = {}

-- LSP key bindings
function mykeymap.setup()
  local mapset = require("my/lib/mapset").mapset
  local quickrun = require("my/lib/quickrun")
  local vfiler = require("my/lib/vfiler")
  local favorite_buffer = require("my/lib/favorite_buffer")

  mapset.n("gx")({ desc = "Tiny code action", require("tiny-code-action").code_action })
  mapset.n("gh")({ desc = "LSP hover", vim.lsp.buf.hover })
  mapset.n("gf")({ desc = "LSP formatting", vim.lsp.buf.format })
  mapset.n("gr")({ desc = "LSP references", vim.lsp.buf.references })
  mapset.n("qd")({ desc = "LSP go to definition", vim.lsp.buf.definition })
  mapset.n("qD")({ desc = "LSP go to declaration", vim.lsp.buf.declaration })
  mapset.n("gi")({ desc = "LSP go to implementation", vim.lsp.buf.implementation })
  mapset.n("gt")({ desc = "LSP go to type definition", vim.lsp.buf.type_definition })
  mapset.n("gn")({ desc = "LSP rename", vim.lsp.buf.rename })
  mapset.n("ga")({ desc = "LSP code action", vim.lsp.buf.code_action })
  mapset.n("ge")({ desc = "Show diagnostics", vim.diagnostic.open_float })
  mapset.n("g]")({ desc = "Next diagnostic", vim.diagnostic.goto_next })
  mapset.n("g[")({ desc = "Previous diagnostic", vim.diagnostic.goto_prev })
  mapset.n("<C-j>")({ desc = "Edge motion down", "<Plug>(edgemotion-j)" })
  mapset.n("<C-k>")({ desc = "Edge motion up", "<Plug>(edgemotion-k)" })
  mapset.n("tt")({ desc = "QuickRun", quickrun.run })
  mapset.n("sa")({ desc = "Startify", ":Startify<CR>" })
  mapset.n("<ESC>")({ desc = "Clear Highlight", ":nohlsearch<CR>" })
  mapset.n("q")({ desc = "Clear Highlight", ":nohlsearch<CR>" })
  mapset.n("<C-c>")({ desc = "QuickRun session cleanup", quickrun.cleanup })
  mapset.n("<C-e>")({ desc = "Start vfiler explorer", vfiler.open })
  mapset.n("s*")({ desc = "Register favorite buffer", favorite_buffer.register })
  mapset.n("s<Space>")({ desc = "Set the favorite buffer if exists", favorite_buffer.jump })
end

return mykeymap
