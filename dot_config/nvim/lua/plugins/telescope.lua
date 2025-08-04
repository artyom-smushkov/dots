return {
    {
        "nvim-telescope/telescope-ui-select.nvim",
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim", build="make"
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" , "nvim-telescope/telescope-fzf-native.nvim"},
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                    fzf  = {},
                },
                pickers = {
                    buffers = {
                        sort_lastused = true  -- Sort by last used, making the previous buffer default
                    },
                    find_files = {
                        find_command = {'rg', '--files', '--hidden', '--glob', '!.git/*'}
                    }
                },
            })
            require("telescope").load_extension("fzf")
            local builtin = require("telescope.builtin")
            -- vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
            -- vim.keymap.set("n", "<leader>ps", builtin.live_grep, {})
            -- vim.keymap.set("n", "<leader>s", builtin.current_buffer_fuzzy_find, {})
            -- vim.keymap.set("n", "<leader>o", builtin.lsp_document_symbols, {})
            -- vim.keymap.set("n", "<leader>b", builtin.buffers, {})
            require("telescope").load_extension("ui-select")
        end,
    },
}
