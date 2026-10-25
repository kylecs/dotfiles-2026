return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local noop = function() end
    telescope.setup({
      defaults = {
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        mappings = {
          -- vertico-style: C-j/C-k move, one Esc quits
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-h>"] = noop,
            ["<C-l>"] = noop,
            ["<Esc>"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = { find_command = { "rg", "--files", "--hidden", "--glob", "!.git" } },
        live_grep = { additional_args = { "--hidden", "--glob", "!.git" } },
        buffers = { sort_mru = true, ignore_current_buffer = true },
      },
    })
    telescope.load_extension("fzf")
  end,
}
