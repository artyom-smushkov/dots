return {
    'https://codeberg.org/esensar/nvim-dev-container',
    config = function ()
        require("devcontainer").setup({
            container_runtime = "docker",
            compose_command = "docker compose"
        })
    end
}
