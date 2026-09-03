local kind_icons = {
  Text = "",
  Method = "󰆧",
  Function = "󰈧",
  Constructor = "",
  Field = "󰈍",
  Variable = "󰈬",
  Class = "",
  Interface = "󰈍",
  Module = "󰆍",
  Property = "󰈢",
  Value = "󰈢",
  Enum = "󰅡",
  Keyword = "⬅",
  Emoji = "󰲿",
  Color = "󰭘",
  Reference = "󰈷",
  File = "󰈭",
  Folder = "󰉿",
}

return {
  "hrsh7th/nvim-cmp",
  name = "nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),
      sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
      },
      completion = {
        keyword_length = 2,
      },
      formatting = {
        format = function(entry, vim_item)
          local kind = cmp.lsp.CompletionItemKind[entry:get_kind()]
          local icon, hl
          if kind and kind_icons[kind] then
            icon, hl = kind_icons[kind], "CmpItemKind" .. kind .. "Icon"
          else
            icon, hl = require("nvim-web-devicons").get_icon(entry.value, nil, { default = "󰈭" })
          end
          vim_item.icon = icon
          vim_item.icon_hl_group = hl
          return vim_item
        end,
      },
    })
  end,
}
