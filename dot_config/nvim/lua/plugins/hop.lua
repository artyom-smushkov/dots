return {
    'smoka7/hop.nvim',
    version = "*",
    opts = {
        keys = 'etovxqpdygfblzhckisuran'
    },
    config = function()
        require('hop').setup({
            vim.keymap.set("n", "<leader>.", require('hop').hint_char1, {})
        })
    end
}
