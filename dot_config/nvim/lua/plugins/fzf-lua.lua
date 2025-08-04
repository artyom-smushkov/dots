return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        -- calling `setup` is optional for customization
        require("fzf-lua").setup({"telescope"})
        vim.keymap.set("n", "<leader>pf", require("fzf-lua").files, {})
        vim.keymap.set("n", "<leader>ps", require("fzf-lua").live_grep, {})
        vim.keymap.set("n", "<leader>s", require("fzf-lua").blines, {})
        vim.keymap.set("n", "<leader>o", require("fzf-lua").lsp_document_symbols, {})
        vim.keymap.set("n", "<leader>b", require("fzf-lua").buffers, {})
        vim.keymap.set("n", "<leader>c", require("fzf-lua").commands, {})
    end
}
