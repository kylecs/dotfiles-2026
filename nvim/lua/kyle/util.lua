local M = {}

local sidebar_fts = { NvimTree = true }

--- Is WIN an ordinary editing window (not floating, not the sidebar)?
function M.is_normal_win(win)
  win = win or vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  return not sidebar_fts[vim.bo[vim.api.nvim_win_get_buf(win)].filetype]
end

function M.normal_wins(tab)
  return vim.tbl_filter(M.is_normal_win, vim.api.nvim_tabpage_list_wins(tab or 0))
end

--- Short display name for a buffer, shared by the tabline and statusline.
function M.bufname(buf)
  if vim.bo[buf].buftype == "terminal" then
    return require("kyle.term").name(buf)
  end
  local ft = vim.bo[buf].filetype
  if ft == "ministarter" then
    return "Dashboard"
  elseif ft == "oil" then
    local dir = require("oil").get_current_dir(buf) or ""
    return vim.fn.fnamemodify(dir, ":~")
  end
  local name = vim.api.nvim_buf_get_name(buf)
  return name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
end

--- Window to show something "other": the previous window, another
--- ordinary window, or a fresh split. Like Emacs' `display-buffer' other-window.
function M.other_window()
  local cur = vim.api.nvim_get_current_win()
  if not M.is_normal_win(cur) then
    cur = M.normal_wins()[1] or cur
    vim.api.nvim_set_current_win(cur)
  end
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  if prev ~= 0 and prev ~= cur and M.is_normal_win(prev) then
    return prev
  end
  for _, w in ipairs(M.normal_wins()) do
    if w ~= cur then
      return w
    end
  end
  vim.cmd(vim.api.nvim_win_get_width(cur) >= 160 and "vsplit" or "split")
  local new = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(cur)
  return new
end

--- Move to a window, never from inside a float (pickers, popups).
function M.nav(dir)
  return function()
    if vim.api.nvim_win_get_config(0).relative ~= "" then
      return
    end
    if vim.fn.mode() == "i" then
      vim.cmd.stopinsert()
    end
    vim.cmd.wincmd(dir)
  end
end

--- Delete the window, or close the tab when it's the only ordinary window.
function M.delete_window_or_tab()
  local wins = M.normal_wins()
  if #wins <= 1 and M.is_normal_win() then
    if #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd.tabclose()
    else
      vim.notify("Last window", vim.log.levels.INFO)
    end
  else
    vim.cmd.close()
  end
end

function M.tab_move(offset)
  local target = vim.fn.tabpagenr() + offset
  if target >= 1 and target <= vim.fn.tabpagenr("$") then
    vim.cmd.tabnext(target)
  end
end

--- Zoom: toggle the current window between maximized and the saved layout.
function M.zoom()
  if vim.t.kyle_zoom then
    vim.cmd(vim.t.kyle_zoom)
    vim.t.kyle_zoom = nil
  else
    vim.t.kyle_zoom = vim.fn.winrestcmd()
    vim.cmd("wincmd _ | wincmd |")
  end
end

--- Kill a buffer but keep its windows (kill-current-buffer).
function M.delete_buffer(buf, force)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  if not force and vim.bo[buf].buftype == "terminal" then
    if vim.fn.jobwait({ vim.bo[buf].channel }, 0)[1] == -1 then
      if vim.fn.confirm(("Kill %q?"):format(M.bufname(buf)), "&Yes\n&No") ~= 1 then
        return
      end
    end
  elseif not force and vim.bo[buf].modified then
    local choice = vim.fn.confirm(("Save changes to %q?"):format(M.bufname(buf)), "&Yes\n&No\n&Cancel")
    if choice == 1 then
      vim.api.nvim_buf_call(buf, vim.cmd.write)
    elseif choice ~= 2 then
      return
    end
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      local alt = vim.fn.bufnr("#")
      if alt > 0 and alt ~= buf and vim.bo[alt].buflisted then
        vim.api.nvim_win_set_buf(win, alt)
      elseif not pcall(vim.cmd.bprevious) or vim.api.nvim_win_get_buf(win) == buf then
        vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
      end
    end)
  end
  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
end

function M.rename_file()
  local old = vim.api.nvim_buf_get_name(0)
  if old == "" then
    return vim.notify("Buffer has no file", vim.log.levels.WARN)
  end
  vim.ui.input({ prompt = "Rename to: ", default = old, completion = "file" }, function(new)
    if not new or new == "" or new == old then
      return
    end
    new = vim.fn.fnamemodify(new, ":p")
    vim.fn.mkdir(vim.fn.fnamemodify(new, ":h"), "p")
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd.update()
    if vim.fn.rename(old, new) ~= 0 then
      return vim.notify("Rename failed", vim.log.levels.ERROR)
    end
    vim.cmd.edit(vim.fn.fnameescape(new))
    vim.api.nvim_buf_delete(buf, { force = true })
  end)
end

--- Minimal Telescope picker over ITEMS. `display(item)` -> string, `on_select(item)`.
function M.pick(title, items, display, on_select, opts)
  opts = opts or {}
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local state = require("telescope.actions.state")
  pickers
    .new({}, {
      prompt_title = title,
      finder = finders.new_table({
        results = items,
        entry_maker = function(item)
          local text = display(item)
          return { value = item, display = text, ordinal = text }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_buf, map)
        actions.select_default:replace(function()
          local entry = state.get_selected_entry()
          actions.close(prompt_buf)
          if entry then
            on_select(entry.value)
          end
        end)
        if opts.on_delete then
          map({ "i", "n" }, "<C-d>", function()
            local entry = state.get_selected_entry()
            actions.close(prompt_buf)
            if entry then
              opts.on_delete(entry.value)
            end
          end)
        end
        return true
      end,
    })
    :find()
end

return M
