return {
  "folke/which-key.nvim",
  lazy = true,
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>f", group = "files" },
      { "<leader>c", group = "consult" },
      { "<leader>b", group = "buffers" },
      { "<leader>w", group = "windows" },
      { "<leader>t", group = "lsp" },
      { "<leader>h", group = "help" },
    },
  },
}
