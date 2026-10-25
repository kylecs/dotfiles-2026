local group = vim.api.nvim_create_augroup("kyle", { clear = true })
local autocmd = function(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = group }, opts))
end

-- global-auto-revert-mode
autocmd({ "FocusGained", "BufEnter", "TermLeave" }, {
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- save-place-mode
autocmd("BufReadPost", {
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lines and vim.bo[ev.buf].filetype ~= "gitcommit" then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
})

autocmd("VimResized", {
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- close throwaway buffers with q
autocmd("FileType", {
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})

-- LSP: the 0.11+ defaults cover grn/gra/grr/gri/gO/K; add the classics
autocmd("LspAttach", {
  callback = function(ev)
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
  end,
})
