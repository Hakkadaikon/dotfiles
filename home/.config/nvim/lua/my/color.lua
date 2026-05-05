local mycolor = {}

function mycolor.setup()
  vim.opt.termguicolors = true -- Enable terminal GUI colors
  vim.opt.winblend = 0
  vim.opt.pumblend = 0

  vim.api.nvim_set_hl(0, "LineAdove", { fg = "#ffe5b4" })
  vim.api.nvim_set_hl(0, "NonText", { fg = "#565f89" })
  vim.api.nvim_set_hl(0, "Whitespace", { fg = "#565f89" })
end

return mycolor
