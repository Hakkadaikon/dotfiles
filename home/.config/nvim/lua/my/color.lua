local mycolor = {}

function mycolor.setup()
  vim.opt.termguicolors = true -- Enable terminal GUI colors
  vim.opt.winblend = 0
  vim.opt.pumblend = 0
end

return mycolor
