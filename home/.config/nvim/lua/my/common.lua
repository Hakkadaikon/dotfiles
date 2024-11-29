local mycommon = {}

function mycommon.setup()
  -- Search settings
  vim.opt.ignorecase = true        -- Case insensitive
  vim.opt.wrapscan = true          -- Wrap around when the search is finished
  vim.opt.incsearch = true         -- Incremental search
  vim.opt.hlsearch = true          -- Highlight search results

  -- View settings
  vim.opt.number = true            -- Show line number
  vim.opt.relativenumber = true    -- Show relative line number
  vim.cmd("highlight LineNr guifg=#5a5a5a") -- Equivalent to `ctermfg=239` in terminal colors

  vim.opt.showcmd = true           -- Show the command you are typing
  vim.opt.list = true              -- Show control characters
  vim.opt.listchars = {            -- Define control characters for display
      tab = "»-",
      trail = "-",
      eol = "↲",
      extends = "»",
      precedes = "«",
      nbsp = "%"
  }
  vim.opt.cursorline = true        -- Highlight selected line
  vim.opt.swapfile = false         -- Don't create swap file
  -- vim.opt.foldenable = false     -- Don't fold the source code
  vim.opt.autochdir = true         -- Change to the directory of open files
  vim.opt.softtabstop = 4          -- Number of spaces for tab
  vim.opt.shiftwidth = 4           -- Number of spaces for smart indent, command
  vim.opt.cmdheight = 2            -- Number of lines the message display field
  vim.opt.laststatus = 2           -- Always show status line
  vim.opt.display:append("lastline") -- Don't omit the characters displayed on the status line
  vim.opt.showmatch = true         -- Bracket highlighting
  vim.opt.matchtime = 1            -- Time to show bracket highlighting
  vim.opt.termguicolors = true     -- Enable terminal GUI colors

  -- Other setting
  vim.opt.errorbells = false       -- Beep suppression at the time of error
  vim.opt.history = 10000          -- Number of saved vim command execution histories
  vim.opt.clipboard = "unnamedplus" -- Copy and paste between vim and other applications
end

return mycommon
