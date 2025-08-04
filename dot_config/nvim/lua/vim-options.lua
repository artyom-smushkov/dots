vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.g.mapleader = " "

vim.opt.swapfile = false

-- Navigate vim panes better
vim.keymap.set('n', '<leader>wk', ':wincmd k<CR>')
vim.keymap.set('n', '<leader>wj', ':wincmd j<CR>')
vim.keymap.set('n', '<leader>wh', ':wincmd h<CR>')
vim.keymap.set('n', '<leader>wl', ':wincmd l<CR>')

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 15
vim.opt.clipboard = 'unnamedplus'
vim.opt.signcolumn = "yes"
vim.o.updatetime = 300

vim.keymap.set('n', ':e', ':e %:h', { noremap = true })
