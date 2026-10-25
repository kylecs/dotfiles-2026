-- Gruvbox dark by default, acario-light on demand. The choice persists, and
-- the terminal's background is painted to match so kitty's padding blends in.
local M = {}

M.themes = {
  { name = "gruvbox", background = "dark" },
  { name = "acario-light", background = "light" },
}

local state = vim.fn.stdpath("state") .. "/kyle-theme"

local function apply(name)
  for _, t in ipairs(M.themes) do
    if t.name == name then
      vim.o.background = t.background
      return pcall(vim.cmd.colorscheme, name)
    end
  end
  return false
end

function M.set(name)
  if apply(name) then
    vim.fn.writefile({ name }, state)
  end
end

function M.toggle()
  local idx = 1
  for i, t in ipairs(M.themes) do
    if t.name == vim.g.colors_name then
      idx = i
    end
  end
  M.set(M.themes[idx % #M.themes + 1].name)
end

function M.pick()
  vim.ui.select(M.themes, {
    prompt = "Theme",
    format_item = function(t)
      return t.name
    end,
  }, function(t)
    if t then
      M.set(t.name)
    end
  end)
end

local function send(seq)
  if #vim.api.nvim_list_uis() > 0 then
    vim.api.nvim_ui_send(seq)
  end
end

local function sync_terminal_bg()
  local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
  if bg then
    send(("\27]11;#%06x\7"):format(bg))
  end
end

function M.load()
  local ok, saved = pcall(vim.fn.readfile, state)
  if not (ok and saved[1] and apply(saved[1])) then
    apply(M.themes[1].name)
  end

  local group = vim.api.nvim_create_augroup("kyle.theme", { clear = true })
  vim.api.nvim_create_autocmd({ "ColorScheme", "UIEnter", "VimResume" }, {
    group = group,
    callback = sync_terminal_bg,
  })
  vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
    group = group,
    callback = function()
      send("\27]111\7") -- restore the terminal's own background
    end,
  })
end

return M
