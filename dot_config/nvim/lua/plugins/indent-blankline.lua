return {
  "lukas-reineke/indent-blankline.nvim",
  name = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    scope = {
      include = {
        node_type = {
          python = { "for_statement", "if_statement", "with_statement", "while_statement" },
        },
      },
      exclude = {
        node_type = {
          python = { "dictionary_comprehension", "list_comprehension", "set_comprehension" },
        },
      },
    },
  },
}
