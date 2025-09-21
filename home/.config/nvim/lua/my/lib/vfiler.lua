M = {}

M.open = function()
  local path = vim.fn.bufname(vim.fn.bufnr())
  if vim.fn.isdirectory(path) ~= 1 then
    path = vim.fn.getcwd()
  end
  path = vim.fn.fnamemodify(path, ":p:h")

  require("vfiler").start(path, {
    options = {
      auto_cd = true,
      auto_resize = true,
      keep = true,
      name = "explorer",
      layout = "left",
      width = 40,
      columns = "indent,name,mode,size",
      show_hidden_files = true,
    },
  })
end

return M
