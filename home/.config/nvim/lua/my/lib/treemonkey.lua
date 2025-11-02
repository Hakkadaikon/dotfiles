local M = {}

M.select = function()
  require("treemonkey").select({ ignore_injections = false })
end

return M
