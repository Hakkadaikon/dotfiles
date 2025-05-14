local mycolorscheme = {}

function mycolorscheme.setup()
  require("lualine").setup({options={theme="material"}})

  vim.cmd("colorscheme material")
  vim.api.nvim_set_hl(0, "LineNr", {fg="#00AFFF", bg="NONE"})
  vim.api.nvim_set_hl(0, "CursorLineNr", {fg="#FFFF00", bg="NONE"})
end

return mycolorscheme
