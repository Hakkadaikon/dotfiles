local mycommon = {}

function mycommon.setup()
  vim.opt.autochdir = true -- Change to the directory of open files
  vim.opt.swapfile = false -- Don't create swap file
  vim.opt.errorbells = false -- Beep suppression at the time of error
  vim.opt.history = 10000 -- Number of saved vim command execution histories
  vim.opt.clipboard = "unnamedplus" -- Copy and paste between vim and other applications
end

return mycommon
