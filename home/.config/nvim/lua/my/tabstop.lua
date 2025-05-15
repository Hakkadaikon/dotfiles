local mytabstop = {}

local tabstop_settings = {
  c = {tabstop = 4, shiftwidth = 4, expandtab = true},
  h = {tabstop = 4, shiftwidth = 4, expandtab = true},
  cpp = {tabstop = 4, shiftwidth = 4, expandtab = true},
  hpp = {tabstop = 4, shiftwidth = 4, expandtab = true},
  cxx = {tabstop = 4, shiftwidth = 4, expandtab = true},
  hxx = {tabstop = 4, shiftwidth = 4, expandtab = true},
  ixx = {tabstop = 4, shiftwidth = 4, expandtab = true},
  cc = {tabstop = 4, shiftwidth = 4, expandtab = true},
  hh = {tabstop = 4, shiftwidth = 4, expandtab = true},
  cs = {tabstop = 4, shiftwidth = 4, expandtab = true},
  js = {tabstop = 2, shiftwidth = 2, expandtab = true},
  ts = {tabstop = 2, shiftwidth = 2, expandtab = true},
  html = {tabstop = 2, shiftwidth = 2, expandtab = true},
  py = {tabstop = 4, shiftwidth = 4, expandtab = true},
  rs = {tabstop = 4, shiftwidth = 4, expandtab = true},
  go = {tabstop = 4, shiftwidth = 4, expandtab = false},
  lua = {tabstop = 2, shiftwidth = 2, expandtab = true},
  vim = {tabstop = 2, shiftwidth = 2, expandtab = true},
  bash = {tabstop = 2, shiftwidth = 2, expandtab = true},
  fish = {tabstop = 2, shiftwidth = 2, expandtab = true},
  sh = {tabstop = 2, shiftwidth = 2, expandtab = true},
  rb = {tabstop = 2, shiftwidth = 2, expandtab = true},
}

local function set_tabstop()
  local ft = vim.bo.filetype
  local config = tabstop_settings[ft]

  if config then
    vim.bo.tabstop = config.tabstop
    vim.bo.shiftwidth = config.shiftwidth
    vim.bo.expandtab = config.expandtab
  else
    -- default setting
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true
  end
end

function mytabstop.setup()
  vim.api.nvim_create_autocmd("FileType", {pattern = "*", callback = set_tabstop})
end

return mytabstop
