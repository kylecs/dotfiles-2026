local opt = vim.opt

-- ui
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.showmode = false -- lualine shows the mode
opt.showtabline = 1 -- only when there is more than one tab
opt.laststatus = 2
opt.winborder = "rounded"
opt.fillchars = { eob = " " }
opt.scrolloff = 10
opt.splitright = true
opt.splitbelow = true
opt.confirm = true

-- editing
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.clipboard = "unnamedplus"
opt.foldlevel = 99 -- folds come from treesitter, start with everything open

-- persistence (recentf / savehist / undo-fu-session)
opt.swapfile = false
opt.undofile = true
opt.autoread = true
opt.shada = "'100,<50,s10,h"
opt.sessionoptions = { "buffers", "curdir", "folds", "tabpages", "winsize", "help", "globals" }

opt.updatetime = 250
opt.timeoutlen = 300

vim.diagnostic.config({
  virtual_text = { spacing = 2, source = "if_many" }, -- flymake-show-diagnostics-at-end-of-line
  severity_sort = true,
  float = { source = "if_many" },
})
