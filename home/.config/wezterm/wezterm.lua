local wezterm = require("wezterm")

local config = wezterm.config_builder()

------------------------------------------------------------------------------
-- common
------------------------------------------------------------------------------
config.automatically_reload_config = true
config.use_ime = true

-------------------------------------------------------------------------------
-- tab
-------------------------------------------------------------------------------
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false

config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

-------------------------------------------------------------------------------
-- window
-------------------------------------------------------------------------------
config.macos_window_background_blur = 10
config.window_background_opacity = 0.75
config.window_decorations = "RESIZE"

config.window_frame = {
  font = wezterm.font({ family = "Hack Nerd Font", weight = "Bold" }),
  font_size = 18.0,
  active_titlebar_bg = "none",
  inactive_titlebar_bg = "none",
}

-- config.color_scheme = 'Dracula+'

config.window_background_gradient = {
  orientation = "Vertical",
  colors = {
    "#0f0c29",
    "#302b63",
    "#24243e",
  },
  interpolation = "Linear",
  blend = "Rgb",
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"

  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end

  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
  }
end)

-------------------------------------------------------------------------------
-- font
-------------------------------------------------------------------------------
config.font_size = 18.0

return config
