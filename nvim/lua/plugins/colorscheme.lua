return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("gruvbox").setup({ italic = { strings = false } })
    require("kyle.theme").load()
  end,
}
