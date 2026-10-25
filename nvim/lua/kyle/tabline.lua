-- Tabs named after their most relevant window, skipping the sidebar
-- (kyle/tab-bar-tab-name).
local util = require("kyle.util")

local M = {}

local function tab_buf(tab)
  local win = vim.api.nvim_tabpage_get_win(tab)
  if not util.is_normal_win(win) then
    win = util.normal_wins(tab)[1] or win
  end
  return vim.api.nvim_win_get_buf(win)
end

function M.render()
  local parts = {}
  local current = vim.api.nvim_get_current_tabpage()
  for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local hl = tab == current and "%#TabLineSel#" or "%#TabLine#"
    local name = util.bufname(tab_buf(tab)):gsub("%%", "%%%%")
    parts[#parts + 1] = ("%s%%%dT %d: %s "):format(hl, i, i, name)
  end
  return table.concat(parts) .. "%#TabLineFill#%T"
end

function M.setup()
  vim.o.tabline = "%!v:lua.require'kyle.tabline'.render()"
end

return M
