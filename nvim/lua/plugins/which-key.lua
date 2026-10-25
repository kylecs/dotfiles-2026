return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "classic",
    delay = 0,
    icons = { mappings = false },
    spec = {
      { "<leader>a", group = "activities" },
      { "<leader>b", group = "buffers" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "files" },
      { "<leader>h", group = "help" },
      { "<leader>p", group = "projects" },
      { "<leader>q", group = "quit" },
      { "<leader>s", group = "search" },
      { "<leader>t", group = "terminal" },
      { "<leader>u", group = "ui" },
      { "<leader>w", group = "windows" },
    },
  },
}
