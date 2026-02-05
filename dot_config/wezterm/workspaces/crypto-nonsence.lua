local wezterm = require 'wezterm'

local config = dofile(os.getenv("HOME") .. "/.config/wezterm/wezterm.lua")

config.default_workspace = "crypto-nonsence"

wezterm.on('gui-startup', function(cmd)
        local project_path = '/home/templarrr/Development/crypto-nonsence/04/'
        
        local tab1, pane1, window = wezterm.mux.spawn_window {
            workspace = 'crypto-nonsence',
            cwd = project_path,
            args = { 'docker', 'exec', '-it', 'crypto_nonsence_dev', '/bin/fish' },
        }
        tab1:set_title('shell')
        
        local tab2, pane2 = window:spawn_tab {
            set_environment_variables = { SHELL = '/usr/bin/fish' },
            cwd = project_path,
            args = {'/bin/fish', '-C', 'eval $(minikube docker-env)' }
        }
        tab2:set_title('kubernetes')

        local tab3, pane3 = window:spawn_tab {
            cwd = project_path,
            args = { '/bin/fish', '-C', 'docker compose -f docker-compose-infrastructure.yml up' }
        }
        tab3:set_title('infrastructure')
        
        tab1:activate()
end)

return config
