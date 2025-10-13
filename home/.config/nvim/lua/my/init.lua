local init = {}

function init.setup()
  local tiny_code = require("my/lib/tiny_code")

  require("my/lazy").setup()
  require("my/common").setup()
  require("my/search").setup()
  require("my/lsp").setup()
  require("my/keymap").setup()
  require("my/tabstop").setup()
  require("tiny-inline-diagnostic").setup(tiny_code.diagnostic_config)
  require("tiny-code-action").setup(tiny_code.action_config)
  require("my/colorscheme").setup()
  require("my/color").setup()
  require("my/display").setup()
end

return init
