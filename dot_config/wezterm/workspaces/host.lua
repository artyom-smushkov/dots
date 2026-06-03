local wezterm = require 'wezterm'

local config = dofile(os.getenv("HOME") .. "/.config/wezterm/wezterm.lua")

config.default_workspace = "localhost"

wezterm.on('gui-startup', function(cmd)
        local tab1, pane1, window = wezterm.mux.spawn_window {
            workspace = 'shallow-research',
            args = { '/bin/zsh' },
        }
        tab1:set_title('shell')
end)

return config
