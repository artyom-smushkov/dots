return {
  "HiPhish/rainbow-delimiters.nvim",
  config = function()
    local augroup = vim.api.nvim_create_augroup("RainbowDelimitersParse", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].ft)
        if not lang then return end
        local ok, parser = pcall(vim.treesitter.get_parser, args.buf, lang)
        if not ok or not parser then return end
        if not require("rainbow-delimiters.lib").get_query(lang, args.buf) then return end
        parser:parse()
      end,
    })
  end,
}
