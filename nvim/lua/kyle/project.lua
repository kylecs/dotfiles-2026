-- A small project.el: roots come from markers, visited projects are
-- remembered, and switching a project sets the tab's cwd (:tcd) so each tab
-- can be its own workspace.
local util = require("kyle.util")

local M = {}

local file = vim.fn.stdpath("data") .. "/kyle-projects.json"
local markers = { "go.mod", "Cargo.toml", "package.json", "deno.json", "pom.xml", "build.gradle", "flake.nix" }
local projects -- roots, most recent first

local function load()
  if not projects then
    local ok, data = pcall(function()
      return vim.json.decode(table.concat(vim.fn.readfile(file), "\n"))
    end)
    projects = ok and type(data) == "table" and data or {}
  end
  return projects
end

local function save()
  vim.fn.mkdir(vim.fn.fnamemodify(file, ":h"), "p")
  vim.fn.writefile({ vim.json.encode(projects) }, file)
end

--- Project root for a path or buffer, or nil when it isn't in a project.
function M.find(source)
  source = source or 0
  if type(source) == "number" then
    local buf = source == 0 and vim.api.nvim_get_current_buf() or source
    if vim.bo[buf].buftype == "terminal" then
      return vim.b[buf].kyle_term_root
    elseif vim.bo[buf].filetype == "oil" then
      source = require("oil").get_current_dir(buf)
    elseif vim.api.nvim_buf_get_name(buf) == "" or vim.bo[buf].buftype ~= "" then
      source = vim.fn.getcwd()
    end
    if not source then
      return nil
    end
  end
  return vim.fs.root(source, ".git") or vim.fs.root(source, markers)
end

--- Project root, falling back to the cwd.
function M.root(source)
  return M.find(source) or vim.fn.getcwd()
end

function M.list()
  return vim.tbl_filter(function(root)
    return vim.fn.isdirectory(root) == 1
  end, load())
end

function M.remember(root)
  load()
  if projects[1] == root then
    return
  end
  projects = vim.tbl_filter(function(p)
    return p ~= root
  end, projects)
  table.insert(projects, 1, root)
  save()
end

function M.forget(root)
  load()
  projects = vim.tbl_filter(function(p)
    return p ~= root
  end, projects)
  save()
end

--- Open a project: set the tab cwd and show its root (project-dired).
function M.open(root)
  vim.cmd.tcd(vim.fn.fnameescape(root))
  M.remember(root)
  require("oil").open(root)
end

local function display(root)
  return vim.fn.fnamemodify(root, ":~")
end

function M.switch()
  util.pick("Projects", M.list(), display, M.open, { on_delete = M.forget })
end

function M.pick_forget()
  util.pick("Forget project", M.list(), display, M.forget)
end

function M.add_under()
  vim.ui.input({ prompt = "Add projects under: ", default = "~/", completion = "dir" }, function(dir)
    if not dir or dir == "" then
      return
    end
    dir = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(dir), ":p"))
    local found = 0
    local skip = function(name)
      local base = vim.fs.basename(name)
      return base ~= "node_modules" and base ~= ".git"
    end
    for name in vim.fs.dir(dir, { depth = 3, skip = skip }) do
      if vim.fs.basename(name) == ".git" then
        M.remember(vim.fs.joinpath(dir, vim.fs.dirname(name)))
        found = found + 1
      end
    end
    vim.notify(("Added %d projects"):format(found))
  end)
end

function M.find_file()
  require("telescope.builtin").find_files({ cwd = M.root(), prompt_title = "Project files" })
end

function M.grep()
  require("telescope.builtin").live_grep({ cwd = M.root(), prompt_title = "Search project" })
end

function M.buffers()
  require("telescope.builtin").buffers({ cwd = M.root(), cwd_only = true })
end

function M.dired()
  require("oil").open(M.root())
end

--- project-query-replace-regexp: rg into the quickfix list, then :cdo s///gc
function M.replace()
  local root = M.root()
  vim.ui.input({ prompt = "Replace (regexp): " }, function(from)
    if not from or from == "" then
      return
    end
    vim.ui.input({ prompt = ("Replace %s with: "):format(from) }, function(to)
      if not to then
        return
      end
      local lines = vim.fn.systemlist({ "rg", "--vimgrep", "--hidden", "--glob", "!.git", "-e", from, root })
      if vim.v.shell_error ~= 0 or #lines == 0 then
        return vim.notify("No matches", vim.log.levels.INFO)
      end
      vim.fn.setqflist({}, " ", { title = "Replace " .. from, lines = lines, efm = "%f:%l:%c:%m" })
      local esc = function(s)
        return (s:gsub("/", "\\/"))
      end
      vim.cmd(("cdo s/\\v%s/%s/gc | update"):format(esc(from), esc(to)))
    end)
  end)
end

--- project-compile: run a command at the project root in a terminal.
function M.compile()
  local root = M.root()
  local last = vim.g.kyle_compile_cmds and vim.g.kyle_compile_cmds[root] or ""
  vim.ui.input({ prompt = "Compile command: ", default = last, completion = "shellcmd" }, function(cmd)
    if not cmd or cmd == "" then
      return
    end
    local cmds = vim.g.kyle_compile_cmds or {}
    cmds[root] = cmd
    vim.g.kyle_compile_cmds = cmds
    require("kyle.term").run(cmd, { cwd = root, root = root })
  end)
end

--- project-vc-dir: lazygit at the root, in the current window.
function M.vc()
  local root = M.root()
  if vim.fn.executable("lazygit") == 0 then
    return require("kyle.term").run("git status", { cwd = root, root = root })
  end
  require("kyle.term").create({
    cmd = "lazygit",
    name = "lazygit",
    cwd = root,
    root = root,
    passthrough_esc = true,
    close_on_exit = true,
  })
end

function M.kill_buffers()
  local root = M.root()
  local prefix = root .. "/"
  local bufs = vim.tbl_filter(function(buf)
    if not vim.bo[buf].buflisted and vim.bo[buf].buftype ~= "terminal" then
      return false
    end
    if vim.bo[buf].buftype == "terminal" then
      return vim.b[buf].kyle_term_root == root
    end
    return vim.startswith(vim.api.nvim_buf_get_name(buf), prefix)
  end, vim.api.nvim_list_bufs())
  if #bufs == 0 then
    return vim.notify("No project buffers", vim.log.levels.INFO)
  end
  if vim.fn.confirm(("Kill %d buffers in %s?"):format(#bufs, display(root)), "&Yes\n&No") ~= 1 then
    return
  end
  for _, buf in ipairs(bufs) do
    util.delete_buffer(buf, vim.bo[buf].buftype == "terminal")
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("kyle.project", { clear = true }),
    callback = function(ev)
      if vim.bo[ev.buf].buftype == "" and vim.api.nvim_buf_get_name(ev.buf) ~= "" then
        local root = M.find(ev.buf)
        if root then
          M.remember(root)
        end
      end
    end,
  })
end

return M
