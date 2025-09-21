local M = {}

M.run = function()
  vim.cmd(":QuickRun")
end

M.cleanup = function()
  return vim.fn["quickrun#is_running"]() == 1 and vim.fn["quickrun#sweep_sessions"]() or "<C-c>"
end

return M
