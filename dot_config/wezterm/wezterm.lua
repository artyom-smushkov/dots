local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_prog = { '/usr/bin/zsh' }

config.font = wezterm.font 'VictorMono Nerd Font'
config.font_size = 11

config.color_scheme = 'Catppuccin Mocha'
config.window_background_opacity = 0.93

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 40

wezterm.on('update-status', function(window, pane)
  local workspace = pane.workspace or config.default_workspace
  window:set_left_status(wezterm.format {
    { Background = { Color = '#45475a' } },
    { Foreground = { Color = '#fab387' } },
    { Text = '  ' .. workspace .. '  ' },
  })
end)

config.keys = {
    {
        key = 't',
        mods = 'ALT',
        action = wezterm.action.SpawnTab 'CurrentPaneDomain'
    }
}

for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'ALT',
        action = wezterm.action.ActivateTab(i - 1),
    })
end

return config
