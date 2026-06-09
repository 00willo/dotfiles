-- Pull in the wezterm API
local wezterm = require('wezterm')

-- Holds the configuration
local config = wezterm.config_builder()

config = {
  automatically_reload_config = true,
  -- enable_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  -- window_decorations = "RESIZE",
  adjust_window_size_when_changing_font_size = false,
  color_scheme = 'Catppuccin Mocha',
  font_size = 14,
  -- To find fonts, use somethign like this `wezterm ls-fonts --list-system |grep JetBrains`
  font = wezterm.font('JetBrainsMono NF SemiBold'),
  -- font = wezterm.font 'JetBrainsMono Nerd Font',
  macos_window_background_blur = 20,
  window_background_opacity = 0.8,
}
return config
