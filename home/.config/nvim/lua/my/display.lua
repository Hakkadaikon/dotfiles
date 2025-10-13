local mydisplay = {}

function mydisplay.setup()
  vim.opt.number = true -- Show line number
  vim.opt.relativenumber = true -- Show relative line number
  vim.opt.cursorline = true -- Highlight selected line

  vim.opt.showcmd = true -- Show the command you are typing
  vim.opt.list = true -- Show control characters
  vim.opt.listchars = { -- Define control characters for display
    tab = "»-",
    trail = "-",
    eol = "↲",
    extends = "»",
    precedes = "«",
    nbsp = "%",
  }

  -- vim.opt.foldenable = false     -- Don't fold the source code
  vim.opt.cmdheight = 2 -- Number of lines the message display field
  vim.opt.laststatus = 2 -- Always show status line
  vim.opt.display:append("lastline") -- Don't omit the characters displayed on the status line
end

return mydisplay
