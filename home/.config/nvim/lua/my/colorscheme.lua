local mycolorscheme = {}

function mycolorscheme.setup()
  require("tokyonight").setup({
    transparent = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent",
    },
  })
  vim.cmd([[colorscheme tokyonight-night]])
end

return mycolorscheme
