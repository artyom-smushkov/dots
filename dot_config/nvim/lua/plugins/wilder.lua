return {
  "gelguy/wilder.nvim",
  config = function()
    local wilder = require("wilder")

    wilder.setup({
      modes = { ":", "/", "?" },
    })

    wilder.set_option("pipeline", {
      wilder.branch(
        wilder.cmdline_pipeline({ fuzzy = 2 }),
        wilder.python_search_pipeline()
      ),
    })

    wilder.set_option("renderer", wilder.popupmenu_renderer(
      wilder.popupmenu_border_theme({
        border = "rounded",
        highlights = {
          border = "Comment",
        },
        highlighter = wilder.basic_highlighter(),
        min_width = "100%",
        max_height = "50%",
        left = {
          " ",
          wilder.popupmenu_devicons(),
        },
        right = {
          wilder.popupmenu_buffer_flags({
            flags = " %a+ ",
            icons = {
              ["%"] = "▸",
              a = "⚑",
              h = "○",
              ["+"] = "●",
            },
          }),
          " ",
          wilder.popupmenu_scrollbar(),
        },
        empty_message = wilder.popupmenu_empty_message_with_spinner(),
      })
    ))
  end,
}
