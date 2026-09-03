local servers = {
  "basedpyright",
  "rust_analyzer",
  "lua_ls",
  "terraformls",
  "dockerls",
  "zls",
  "vue_ls",
  "ruff",
}

return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = servers,
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            typeCheckingMode = "basic",
          },
        },
      })
      vim.lsp.config("terraformls", {
        filetypes = { "tf", "terraform", "terraform-vars" },
      })

      vim.diagnostic.config({
        virtual_text = false,
        underline = true,
      })
      vim.api.nvim_set_hl(0, "DiagnosticError", { underline = true, fg = "#f38ba8" })
      vim.api.nvim_set_hl(0, "DiagnosticWarning", { underline = true, fg = "#f9e2af" })
      vim.api.nvim_set_hl(0, "DiagnosticInfo", { underline = true, fg = "#a6e3a1" })

      local lsp_augroup = vim.api.nvim_create_augroup("lsp", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = lsp_augroup,
        callback = function(ev)
          local buf = ev.buf
          vim.keymap.set("n", "<leader>tr", vim.lsp.buf.rename, { buffer = buf, desc = "rename" })
          vim.keymap.set("n", "<leader>ta", vim.lsp.buf.code_action, { buffer = buf, desc = "actions" })
          vim.keymap.set("n", "<leader>tt", vim.lsp.buf.definition, { buffer = buf, desc = "find definition" })
          vim.keymap.set("n", "<leader>th", vim.lsp.buf.hover, { buffer = buf, desc = "hover" })
          vim.keymap.set("n", "<leader>tR", vim.lsp.buf.references, { buffer = buf, desc = "references" })
        end,
      })
    end,
  },
}
