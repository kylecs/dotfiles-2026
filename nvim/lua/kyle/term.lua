-- Terminals hosted by Neovim, with the same key routing as evil-ghostel:
--   * terminals always land in normal mode (so H/L etc. keep working); press
--     i/a to type into the program
--   * <Esc> drops back to normal mode for motions / yank / search over the scrollback
--   * in normal mode, <Esc> <C-c> <Up> <Down> are forwarded to the program
--   * <C-Esc> always sends a literal escape (for vim, fzf, claude... inside)
--   * <C-h/j/k/l> always move between windows (see config/keymaps.lua)
--   * <C-Space> opens the leader menu straight from terminal mode
local util = require("kyle.util")

local M = {}

local counter = 0
local last -- most recently focused terminal buffer

local function is_term(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal"
end

--- Directory of the current buffer (Emacs' default-directory).
local function buf_dir()
  local buf = vim.api.nvim_get_current_buf()
  if is_term(buf) then
    return vim.b[buf].kyle_term_cwd or vim.fn.getcwd()
  elseif vim.bo[buf].filetype == "oil" then
    return require("oil").get_current_dir(buf) or vim.fn.getcwd()
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name ~= "" and vim.bo[buf].buftype == "" then
    local dir = vim.fn.fnamemodify(name, ":p:h")
    if vim.fn.isdirectory(dir) == 1 then
      return dir
    end
  end
  return vim.fn.getcwd()
end

function M.list(root)
  local terms = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_term(buf) and (root == nil or vim.b[buf].kyle_term_root == root) then
      terms[#terms + 1] = buf
    end
  end
  return terms
end

function M.name(buf)
  local b = vim.b[buf]
  local title = b.kyle_term_name
  if not title then
    title = b.term_title
    if not title or title:match("^term://") then
      title = vim.fn.fnamemodify(b.kyle_term_cwd or vim.fn.getcwd(), ":~")
    end
  end
  return ("[%s] %s"):format(b.kyle_term_id or "term", title)
end

--- Show BUF in WIN and focus it.
function M.focus(win, buf)
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_set_current_win(win)
end

--- Create a terminal. opts: win, cwd, root, cmd (string), name,
--- passthrough_esc (Esc goes to the program), close_on_exit.
function M.create(opts)
  opts = opts or {}
  local win = opts.win or vim.api.nvim_get_current_win()
  if not util.is_normal_win(win) then
    win = util.other_window()
  end
  vim.api.nvim_set_current_win(win)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_win_set_buf(win, buf)

  local cwd = opts.cwd or buf_dir()
  counter = counter + 1
  vim.b[buf].kyle_term_id = counter
  vim.b[buf].kyle_term_cwd = cwd
  vim.b[buf].kyle_term_root = opts.root or require("kyle.project").find(cwd) or cwd
  vim.b[buf].kyle_term_name = opts.name
  vim.b[buf].kyle_term_passthrough = opts.passthrough_esc

  local cmd = opts.cmd and { vim.o.shell, vim.o.shellcmdflag, opts.cmd } or { vim.o.shell }
  vim.fn.jobstart(cmd, {
    term = true,
    cwd = cwd,
    on_exit = opts.close_on_exit and function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          util.delete_buffer(buf, true)
        end
      end)
    end or nil,
  })
  -- park the cursor on the last line so the window follows output
  vim.cmd.normal({ "G", bang = true })
  return buf
end

--- Reuse a terminal (focus it if visible, else show it in the other window),
--- or create one. With ROOT, only that project's terminals count.
function M.open(root)
  local terms = M.list(root)
  local buf = (last and vim.tbl_contains(terms, last)) and last or terms[#terms]
  if not buf then
    return M.create({ win = util.other_window(), cwd = root, root = root })
  end
  local tab = vim.api.nvim_get_current_tabpage()
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    if vim.api.nvim_win_get_tabpage(win) == tab then
      return M.focus(win, buf)
    end
  end
  M.focus(util.other_window(), buf)
end

function M.new()
  M.create()
end

function M.new_project()
  local root = require("kyle.project").root()
  M.create({ cwd = root, root = root })
end

--- Run CMD in a terminal in the other window (project-compile).
function M.run(cmd, opts)
  opts = vim.tbl_extend("force", { win = util.other_window(), cmd = cmd, name = cmd }, opts or {})
  return M.create(opts)
end

local function current_win()
  return util.is_normal_win() and vim.api.nvim_get_current_win() or util.other_window()
end

function M.cycle(offset)
  local terms = M.list()
  if #terms == 0 then
    return vim.notify("No terminals", vim.log.levels.INFO)
  end
  local idx = 0
  for i, buf in ipairs(terms) do
    if buf == vim.api.nvim_get_current_buf() then
      idx = i
    end
  end
  if idx == 0 then
    idx = offset > 0 and 0 or #terms + 1
  end
  M.focus(current_win(), terms[(idx + offset - 1) % #terms + 1])
end

function M.pick(root)
  local terms = M.list(root)
  if #terms == 0 then
    return vim.notify("No terminals", vim.log.levels.INFO)
  end
  util.pick(root and "Project terminals" or "Terminals", terms, function(buf)
    local cwd = vim.fn.fnamemodify(vim.b[buf].kyle_term_cwd or "", ":~")
    return ("%s  %s"):format(M.name(buf), cwd)
  end, function(buf)
    M.focus(current_win(), buf)
  end, {
    on_delete = function(buf)
      util.delete_buffer(buf)
    end,
  })
end

--- Type KEYS into the terminal job as if in terminal mode (uses the job's
--- own key encoding), then return to normal mode unless STAY.
function M.send(keys, stay)
  vim.api.nvim_feedkeys(vim.keycode("i" .. keys .. (stay and "" or "<C-\\><C-n>")), "n", false)
end

local function require_term()
  if not is_term(vim.api.nvim_get_current_buf()) then
    vim.notify("Not a terminal", vim.log.levels.WARN)
    return false
  end
  return true
end

function M.clear()
  if require_term() then
    M.send("<C-l>", true)
  end
end

function M.clear_scrollback()
  if require_term() then
    local sb = vim.bo.scrollback
    vim.bo.scrollback = 1
    vim.bo.scrollback = sb
    M.send("<C-l>", true)
  end
end

function M.rename()
  if not require_term() then
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  vim.ui.input({ prompt = "Terminal name: ", default = vim.b[buf].kyle_term_name or "" }, function(name)
    if name then
      vim.b[buf].kyle_term_name = name ~= "" and name or nil
      vim.cmd.redrawtabline()
      vim.cmd.redrawstatus()
    end
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("kyle.term", { clear = true })

  vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    callback = function(ev)
      local buf = ev.buf
      if not vim.b[buf].kyle_term_id then -- started some other way, e.g. :terminal
        counter = counter + 1
        vim.b[buf].kyle_term_id = counter
        vim.b[buf].kyle_term_cwd = vim.fn.getcwd()
        vim.b[buf].kyle_term_root = vim.fn.getcwd()
      end
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = "no"
      vim.opt_local.scrolloff = 0

      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
      end
      if not vim.b[buf].kyle_term_passthrough then
        map("t", "<Esc>", "<C-\\><C-n>", "Normal mode")
      end
      map("t", "<C-Esc>", "<Esc>", "Send escape")
      for _, key in ipairs({ "<Esc>", "<C-Esc>", "<C-c>", "<Up>", "<Down>" }) do
        map("n", key, function()
          M.send(key == "<C-Esc>" and "<Esc>" or key)
        end, "Send " .. key)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = group,
    callback = function(ev)
      if is_term(ev.buf) then
        last = ev.buf
        -- never carry terminal mode into a terminal you navigate to
        if vim.fn.mode() == "t" then
          vim.cmd.stopinsert()
        end
      end
    end,
  })

  -- Replace the built-in auto-close with a tmux-like one: when a shell exits
  -- cleanly, close its window (unless it's the last one) and kill the buffer.
  for _, au in ipairs(vim.api.nvim_get_autocmds({ group = "nvim.terminal", event = "TermClose" })) do
    if au.desc and au.desc:match("^Automatically close") then
      vim.api.nvim_del_autocmd(au.id)
    end
  end
  vim.api.nvim_create_autocmd("TermClose", {
    group = group,
    nested = true,
    callback = function(ev)
      if vim.v.event.status ~= 0 then
        return
      end
      local info = vim.api.nvim_get_chan_info(vim.bo[ev.buf].channel)
      if table.concat(info.argv or {}, " ") ~= vim.o.shell then
        return
      end
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(ev.buf) then
          return
        end
        for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
          if #util.normal_wins(vim.api.nvim_win_get_tabpage(win)) > 1 then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
        util.delete_buffer(ev.buf, true)
      end)
    end,
  })

  -- leader menu straight from terminal mode (and normal mode, for muscle memory)
  vim.keymap.set({ "n", "t" }, "<C-Space>", function()
    if vim.fn.mode() == "t" then
      vim.cmd.stopinsert()
    end
    vim.schedule(function()
      require("which-key").show({ keys = "<leader>", mode = "n" })
    end)
  end, { desc = "Leader" })
end

return M
