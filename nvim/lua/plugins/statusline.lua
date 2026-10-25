-- doom-modeline: no icons, short file name, modal
local function name()
  return require("kyle.util").bufname(0)
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
      lualine_a = { "mode" },
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
