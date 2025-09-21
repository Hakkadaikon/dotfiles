--- https://zenn.dev/monaqa/articles/2025-07-23-vim-keymap-set-dsl
local M = {}

--- @class mapset_opts: vim.keymap.set.Opts
--- @field [1] map_body
--- @alias mapset_inner fun(t: mapset_opts):nil

--- @param mode string | string[]
--- @param buffer_local boolean?
--- @return fun(string): mapset_inner
local function mapset_with_mode(mode, buffer_local)
  ---@param lhs string
  ---@return mapset_inner
  return function(lhs)
    ---@param t mapset_opts
    return function(t)
      local body = t[1]
      t[1] = nil
      if t.buffer == nil then
        t.buffer = buffer_local
      end
      vim.keymap.set(mode, lhs, body, t)
    end
  end
end

---@alias map_body string | fun():nil|string

---@class mapset_opts: vim.keymap.set.Opts
---@field [1] map_body
---@alias mapset_inner fun(t: mapset_opts):nil

---@param mode string | string[]
---@param buffer_local boolean?
---@return fun(string): mapset_inner
local function mapset_with_mode(mode, buffer_local)
  ---@param lhs string
  ---@return mapset_inner
  return function(lhs)
    ---@param t mapset_opts
    return function(t)
      local body = t[1]
      t[1] = nil
      if t.buffer == nil then
        t.buffer = buffer_local
      end
      vim.keymap.set(mode, lhs, body, t)
    end
  end
end

M.mapset = {
  n = mapset_with_mode("n"),
  x = mapset_with_mode("x"),
  o = mapset_with_mode("o"),
  i = mapset_with_mode("i"),
  c = mapset_with_mode("c"),
  s = mapset_with_mode("x"),
  t = mapset_with_mode("t"),
  nx = mapset_with_mode({ "n", "x" }),
  xs = mapset_with_mode({ "x", "s" }),
  xo = mapset_with_mode({ "x", "o" }),
  nxo = mapset_with_mode({ "n", "x", "o" }),
  ic = mapset_with_mode({ "i", "c" }),
  ia = mapset_with_mode("ia"),
  ca = mapset_with_mode("ca"),
  with_mode = mapset_with_mode,
}

M.mapset_local = {
  n = mapset_with_mode("n", true),
  x = mapset_with_mode("x", true),
  o = mapset_with_mode("o", true),
  i = mapset_with_mode("i", true),
  c = mapset_with_mode("c", true),
  s = mapset_with_mode("s", true),
  t = mapset_with_mode("t", true),
  nx = mapset_with_mode({ "n", "x" }, true),
  xs = mapset_with_mode({ "x", "s" }, true),
  xo = mapset_with_mode({ "x", "o" }, true),
  nxo = mapset_with_mode({ "n", "x", "o" }, true),
  ic = mapset_with_mode({ "i", "c" }, true),
  ia = mapset_with_mode("ia", true),
  ca = mapset_with_mode("ca", true),
}

return M
