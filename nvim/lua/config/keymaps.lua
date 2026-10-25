-- Port of the Emacs `general' config: global keys first, then the SPC leader tree.
local util = require("kyle.util")
local term = require("kyle.term")
local project = require("kyle.project")

local map = vim.keymap.set

local function tb(picker, opts)
  return function()
    require("telescope.builtin")[picker](opts)
  end
end

--;; global keys
map({ "n", "i", "x" }, "<C-s>", "<Cmd>write<CR>", { desc = "Save" })
-- window navigation from everywhere, terminals included. In insert mode
-- blink.cmp claims C-j/C-k while its menu is open and falls back to these.
for key, dir in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
  map({ "n", "i", "t" }, "<C-" .. key .. ">", util.nav(dir), { desc = "Window " .. dir })
end
map({ "n", "x" }, "H", function()
  util.tab_move(-1)
end, { desc = "Previous tab" })
map({ "n", "x" }, "L", function()
  util.tab_move(1)
end, { desc = "Next tab" })
map("n", "-", function()
  require("oil").open()
end, { desc = "Parent directory" })
map("n", "<Esc>", "<Cmd>nohlsearch<CR>")

--;; leader tree
local function leader(lhs, rhs, desc, mode)
  map(mode or "n", "<leader>" .. lhs, rhs, { desc = desc })
end

-- top level
leader(":", tb("commands"), "M-x")
leader(".", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h"), prompt_title = "Find file here" })
end, "Find file")
leader(",", tb("buffers"), "Switch buffer")
leader("?", tb("keymaps"), "Show active keybindings")
leader("j", function()
  require("flash").jump()
end, "Jump to visible text", { "n", "x", "o" })

-- code
leader("cr", vim.lsp.buf.rename, "Rename symbol")
leader("cf", tb("lsp_references"), "Find references")
leader("ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
leader("cd", vim.diagnostic.open_float, "Line diagnostics")
leader("cF", function()
  require("conform").format({ async = true })
end, "Format buffer")

-- files
leader("ff", tb("find_files"), "Find file")
leader("fs", "<Cmd>write<CR>", "Save file")
leader("fS", "<Cmd>wall<CR>", "Save all files")
leader("fd", function()
  require("oil").open()
end, "Open directory")
leader("fr", tb("oldfiles"), "Recent files")
leader("fR", util.rename_file, "Rename file")

-- buffers
leader("bb", tb("buffers"), "Switch buffer")
leader("bl", tb("buffers", { ignore_current_buffer = false }), "List buffers")
leader("bd", function()
  util.delete_buffer(0)
end, "Delete (kill) buffer")
leader("bn", "<Cmd>bnext<CR>", "Next buffer")
leader("bp", "<Cmd>bprevious<CR>", "Previous buffer")
leader("br", function()
  vim.ui.input({ prompt = "Rename buffer: ", default = vim.fn.bufname() }, function(name)
    if name and name ~= "" then
      vim.cmd.file(vim.fn.fnameescape(name))
    end
  end)
end, "Rename buffer")
leader("bR", "<Cmd>edit!<CR>", "Revert buffer")

-- activities (named sessions)
local function session_name(cb)
  local current = vim.v.this_session ~= "" and vim.fs.basename(vim.v.this_session) or nil
  vim.ui.input({ prompt = "Activity name: ", default = current }, function(name)
    if name and name ~= "" then
      cb(name)
    end
  end)
end
local function write_session()
  session_name(function(name)
    MiniSessions.write(name)
  end)
end
leader("an", write_session, "New activity")
leader("ad", write_session, "Define activity")
leader("aa", function()
  MiniSessions.select("read")
end, "Select activity")
leader("as", function()
  MiniSessions.write()
end, "Save activity")
leader("ab", tb("buffers"), "Activity buffer")
leader("ag", function()
  if vim.v.this_session ~= "" then
    MiniSessions.read(vim.fs.basename(vim.v.this_session), { force = true })
  end
end, "Revert activity")
leader("ak", function()
  MiniSessions.select("delete")
end, "Kill activity")
leader("ax", function()
  MiniSessions.select("delete")
end, "Discard activity")
leader("al", function()
  MiniSessions.select("read")
end, "List activities")

-- projects
leader("pp", project.switch, "Switch project")
leader("pa", project.add_under, "Add projects")
leader("pf", project.find_file, "Find file")
leader("pd", project.dired, "Project directory")
leader("pb", project.buffers, "Switch buffer")
leader("ps", project.grep, "Search project")
leader("pr", project.replace, "Replace in project")
leader("pc", project.compile, "Compile project")
leader("pt", function()
  term.open(project.root())
end, "Project terminal")
leader("pv", project.vc, "Version control")
leader("pk", project.kill_buffers, "Kill project buffers")
leader("px", project.pick_forget, "Forget project")

-- windows
leader("wt", function()
  vim.cmd.tabnew()
  MiniStarter.open()
end, "New tab")
leader("wh", "<C-w>h", "Window left")
leader("wj", "<C-w>j", "Window down")
leader("wk", "<C-w>k", "Window up")
leader("wl", "<C-w>l", "Window right")
leader("wv", "<Cmd>vsplit<CR>", "Split right")
leader("ws", "<Cmd>split<CR>", "Split below")
leader("wd", util.delete_window_or_tab, "Delete window or tab")
leader("wo", "<Cmd>only<CR>", "Delete other windows")
leader("ww", "<C-w>w", "Next window")
leader("wr", "<C-w>r", "Rotate windows down")
leader("wR", "<C-w>R", "Rotate windows up")
leader("w=", "<C-w>=", "Balance windows")
leader("wz", util.zoom, "Maximize window (toggle)")
leader("wT", "<C-w>T", "Move window to new tab")

-- search
leader("sl", tb("current_buffer_fuzzy_find"), "Search lines")
leader("sg", tb("live_grep"), "Search project")
leader("si", function()
  local has_symbols = #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/documentSymbol" }) > 0
  require("telescope.builtin")[has_symbols and "lsp_document_symbols" or "treesitter"]()
end, "Buffer symbols")
leader("sd", tb("diagnostics"), "Diagnostics")
leader("sm", tb("marks"), "Marks")
leader("sr", tb("resume"), "Resume last search")

-- sidebar
leader("e", function()
  local api = require("nvim-tree.api")
  if api.tree.is_visible() then
    api.tree.close()
  else
    api.tree.open({ path = project.root(), find_file = true })
  end
end, "Toggle project tree")

-- terminals
leader("tt", function()
  term.open()
end, "Open terminal")
leader("tn", term.new, "New terminal")
leader("tp", term.new_project, "New project terminal")
leader("tb", function()
  term.pick()
end, "Terminal buffers")
leader("tB", function()
  term.pick(project.root())
end, "Project terminal buffers")
leader("t]", function()
  term.cycle(1)
end, "Next terminal")
leader("t[", function()
  term.cycle(-1)
end, "Previous terminal")
leader("tc", term.clear, "Clear screen")
leader("tC", term.clear_scrollback, "Clear scrollback")
leader("tr", term.rename, "Rename terminal")

-- ui
leader("ut", function()
  require("kyle.theme").toggle()
end, "Toggle theme")
leader("uT", function()
  require("kyle.theme").pick()
end, "Pick theme")
leader("uw", "<Cmd>set wrap!<CR>", "Toggle wrap")

-- help
leader("hh", tb("help_tags"), "Help tags")
leader("hk", tb("keymaps"), "Describe key")
leader("hb", tb("keymaps"), "Describe bindings")
leader("hm", function()
  require("which-key").show({ global = false })
end, "Buffer-local keys")
leader("hc", "<Cmd>Inspect<CR>", "Describe character")
leader("ho", function()
  vim.cmd.help(vim.fn.expand("<cword>"))
end, "Help for word")
leader("hH", tb("highlights"), "Highlight groups")
leader("hl", "<Cmd>Lazy<CR>", "Plugins")

-- quit
leader("qq", "<Cmd>confirm qall<CR>", "Quit")
