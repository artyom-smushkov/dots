return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<Leader>s", desc = "search" },
    { "<Leader>bb", desc = "switch buffer" },
    { "<Leader>cr", desc = "ripgrep" },
    { "<Leader>co", desc = "outline" },
    { "<Leader>ch", desc = "history" },
    { "<Leader>pf", desc = "find file" },
    { "<Leader>fh", desc = "help" },
  },
  cmd = { "GitGrep" },
  config = function()
    require("telescope").setup({})

    local builtin = require("telescope.builtin")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local sorters = require("telescope.sorters")

    local function git_grep(opts)
      opts = opts or {}

      local toplevel = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
      if vim.v.shell_error ~= 0 or not toplevel[1] then
        vim.notify("GitGrep: not a git repository", vim.log.levels.WARN)
        return
      end
      local root = toplevel[1]

      local function entry_maker(line)
        local path, lnum, text = line:match("^(.-):(%d+):(.*)$")
        if not path then
          return nil
        end
        return {
          value = line,
          filename = path,
          path = vim.fs.joinpath(root, path),
          lnum = tonumber(lnum),
          text = text,
          display = line,
          ordinal = line,
        }
      end

      pickers.new(opts, {
        prompt_title = "Git Grep",
        finder = finders.new_dynamic({
          fn = function(prompt)
            if not prompt or prompt == "" then
              return {}
            end
            return vim.fn.systemlist({ "git", "grep", "-n", "-I", "--", prompt })
          end,
          entry_maker = entry_maker,
        }),
        previewer = conf.grep_previewer(opts),
        sorter = sorters.highlighter_only(opts),
        push_cursor_on_edit = true,
      }):find()
    end

    vim.api.nvim_create_user_command("GitGrep", function()
      git_grep()
    end, {})

    local map = vim.keymap.set
    map("n", "<Leader>s", builtin.current_buffer_fuzzy_find, { desc = "search" })
    map("n", "<Leader>bb", builtin.buffers, { desc = "switch buffer" })
    map("n", "<Leader>cr", builtin.live_grep, { desc = "ripgrep" })
    map("n", "<Leader>co", builtin.lsp_document_symbols, { desc = "outline" })
    map("n", "<Leader>ch", builtin.search_history, { desc = "history" })
    map("n", "<Leader>pf", builtin.find_files, { desc = "find file" })
    map("n", "<Leader>fh", builtin.help_tags, { desc = "help" })
  end,
}
