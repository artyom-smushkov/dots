local langs = {
  "python",
  "ecma",
  "jsx",
  "javascript",
  "typescript",
  "tsx",
  "rust",
  "lua",
  "bash",
  "dockerfile",
  "terraform",
  "markdown",
  "vim",
}

return {
  "neovim-treesitter/nvim-treesitter",
  dependencies = { "neovim-treesitter/treesitter-parser-registry" },
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install(langs)

    local augroup = vim.api.nvim_create_augroup("TreesitterFileType", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if type(ft) == "table" then ft = ft[1] end
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then return end
        if not vim.treesitter.get_parser(args.buf, lang) then
          require("nvim-treesitter").install(lang)
          return
        end
        vim.treesitter.start(args.buf, lang)
      end,
    })
  end,
}
