-- fearless leaders
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.lazy")
require("config.autocmds")
require("config.keymaps")

require("kyle.term").setup()
require("kyle.project").setup()
require("kyle.tabline").setup()
