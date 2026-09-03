vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set
local noop = function() end

map("n", "<Leader>pf", noop, { desc = "find file" })
map("n", "<Leader>fs", function() vim.cmd("w") end, { desc = "save file" })
map("n", "<Leader>fd", noop, { desc = "dired" })
map("n", "<Leader>fh", noop, { desc = "help" })

map("n", "<Leader>co", noop, { desc = "outline" })
map("n", "<Leader>cr", noop, { desc = "ripgrep" })
map("n", "<Leader>ch", noop, { desc = "history" })

map("n", "<Leader>s", noop, { desc = "search" })

map("n", "<Leader>bb", noop, { desc = "switch buffer" })
map("n", "<Leader>be", function()
  local buf = vim.api.nvim_get_current_buf()
  if #vim.api.nvim_list_wins() > 1 then
    vim.cmd("wincmd c")
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  else
    vim.cmd("q!")
  end
end, { desc = "kill buffer and window/frame" })
map("n", "<Leader>bk", function() vim.cmd("bd!") end, { desc = "kill buffer" })

map("n", "<Leader>w", "<C-w>", { desc = "window" })

map("n", "<Leader>g", noop, { desc = "magit" })

map("n", "<Leader>tr", noop, { desc = "rename" })
map("n", "<Leader>ta", noop, { desc = "actions" })
map("n", "<Leader>tt", noop, { desc = "find definition" })

map("n", "<Leader>hh", function() vim.cmd("h") end, { desc = "help" })

map("n", "<Leader>p", noop, { desc = "project" })
map("n", "<Leader>u", noop, { desc = "universal argument" })
