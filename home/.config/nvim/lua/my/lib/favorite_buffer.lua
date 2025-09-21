local M = {}

local favorite_buffer = nil

M.register = function()
  favorite_buffer = vim.fn.bufnr()
  vim.notify("Saved as favorite buffer: " .. vim.fn.bufname(favorite_buffer))
end

M.jump = function()
  if favorite_buffer ~= nil then
    vim.cmd.buffer(favorite_buffer)
  end
end

return M
