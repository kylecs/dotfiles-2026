-- avy-goto-char-timer, on <leader>j only
return {
  "folke/flash.nvim",
  lazy = true,
  opts = {
    modes = {
      char = { enabled = false },
      search = { enabled = false },
    },
  },
}
