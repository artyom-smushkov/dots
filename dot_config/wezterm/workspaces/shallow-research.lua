local wezterm = require 'wezterm'

local config = dofile(os.getenv("HOME") .. "/.config/wezterm/wezterm.lua")

config.default_workspace = "shallow-research"

wezterm.on('gui-startup', function(cmd)
        local project_path = '/home/templarrr/Development/shallow-research/'
        
        local tab1, pane1, window = wezterm.mux.spawn_window {
            workspace = 'shallow-research',
            cwd = project_path,
            args = { 'docker', 'exec', '-it', 'shallow_research_dev', '/bin/fish' },
        }
        tab1:set_title('shell')
        
        local tab2, pane2 = window:spawn_tab {
            cwd = project_path,
            args = { 'docker', 'exec', '-it', 'shallow_research_dev', '/bin/bash', '-c', 'python src/shallow-research.py; /bin/fish' },
        }
        tab2:set_title('server')
        
        tab1:activate()
end)

return config
