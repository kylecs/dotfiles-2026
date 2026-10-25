-- doom-modeline: no icons, short file name, modal
local function name()
  return require("kyle.util").bufname(0)
end

-- terminal mode in yellow, so it's obvious when keys go to the program
local function mode_color()
  if vim.fn.mode() == "t" then
    local warn = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn", link = false })
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    local hex = function(c)
      return c and ("#%06x"):format(c)
    end
    return { bg = hex(warn.fg), fg = hex(normal.bg), gui = "bold" }
  end
end

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      icons_enabled = false,
      component_separators = "",
      section_separators = "",
    },
    sections = {
      lualine_a = { { "mode", color = mode_color } },
      lualine_b = { "branch", "diff" },
      lualine_c = { { name }, { "diagnostics" } },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_c = { { name } },
      lualine_x = { "location" },
    },
    extensions = { "nvim-tree", "lazy", "quickfix" },
  },
}
