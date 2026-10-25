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

    -- buffer pickers show terminals by their tab/statusline name, not term://...
    local make_entry = require("telescope.make_entry")
    local gen_from_buffer = make_entry.gen_from_buffer
    make_entry.gen_from_buffer = function(opts)
      local make = gen_from_buffer(opts)
      return function(item)
        local entry = make(item)
        if entry and vim.bo[item.bufnr].buftype == "terminal" then
          local name = require("kyle.util").bufname(item.bufnr)
          entry.value, entry.filename = name, name
          entry.ordinal = item.bufnr .. " : " .. name
          local icon, icon_hl = require("telescope.utils").get_devicons(name, opts.disable_devicons)
          local bufnr = ("%" .. opts.bufnr_width .. "d"):format(item.bufnr)
          local text = ("%s %s %s %s"):format(bufnr, entry.indicator, icon, name)
          -- same highlights as the stock buffer entries
          local ind = #bufnr + 1
          local hls = {
            { { 0, #bufnr }, "TelescopeResultsNumber" },
            { { ind, ind + #entry.indicator }, "TelescopeResultsComment" },
          }
          if icon_hl then
            local ic = ind + #entry.indicator + 1
            hls[#hls + 1] = { { ic, ic + #icon }, icon_hl }
          end
          entry.display = function()
            return text, hls
          end
        end
        return entry
      end
    end
  end,
}
