-- mini.starter: dashboard (activities / projects / recents)
-- mini.sessions: named sessions standing in for activities
-- mini.pairs: electric-pair-mode
local function banner()
  local path = vim.fn.stdpath("config") .. "/assets/banner.txt"
  local ok, lines = pcall(vim.fn.readfile, path)
  return ok and table.concat(lines, "\n") or "neovim"
end

local function projects_section()
  local items = {}
  for i, root in ipairs(require("kyle.project").list()) do
    if i > 5 then
      break
    end
    items[#items + 1] = {
      name = vim.fn.fnamemodify(root, ":~"),
      action = function()
        require("kyle.project").open(root)
      end,
      section = "Projects",
    }
  end
  if #items == 0 then
    items[1] = { name = "--- No projects ---", action = "", section = "Projects" }
  end
  return items
end

return {
  "nvim-mini/mini.nvim",
  lazy = false,
  config = function()
    require("mini.pairs").setup()

    require("mini.sessions").setup({
      autowrite = true,
      directory = vim.fn.stdpath("data") .. "/sessions",
      file = "", -- no local Session.vim files
    })

    local starter = require("mini.starter")
    starter.setup({
      header = banner(),
      footer = "",
      items = {
        starter.sections.sessions(5, true),
        projects_section,
        starter.sections.recent_files(5, false, false),
      },
      content_hooks = {
        starter.gen_hook.adding_bullet("  "),
        starter.gen_hook.aligning("center", "center"),
      },
      query_updaters = "", -- j/k move instead of filtering
      silent = true,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniStarterOpened",
      group = vim.api.nvim_create_augroup("kyle.starter", { clear = true }),
      callback = function(ev)
        local map = function(lhs, dir)
          vim.keymap.set("n", lhs, function()
            MiniStarter.update_current_item(dir)
          end, { buffer = ev.buf })
        end
        map("j", "next")
        map("k", "prev")
      end,
    })
  end,
}
