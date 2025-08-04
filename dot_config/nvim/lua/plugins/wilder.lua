return {
    'gelguy/wilder.nvim',
    config = function()
        require('wilder').setup({
            modes = {':', '/', '?'}
        })
        require('wilder').set_option('renderer', require('wilder').popupmenu_renderer(
            require('wilder').popupmenu_border_theme({
                highlighter = require('wilder').basic_highlighter(),
                min_width = '100%', -- minimum height of the popupmenu, can also be a number
                min_height = '20%', -- to set a fixed height, set max_height to the same value
                max_height = '20%',
                reverse = 0,        -- if 1, shows the candidates from bottom to top
            })
        ))
    end,
}
