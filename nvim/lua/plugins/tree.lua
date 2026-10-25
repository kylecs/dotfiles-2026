-- dirvish-side: project tree sidebar that follows the current file
return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFindFile" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    hijack_netrw = false, -- oil owns directory buffers
    disable_netrw = false,
    hijack_directories = { enable = false },
    update_focused_file = { enable = true },
    view = { width = 32, signcolumn = "no" },
    renderer = { group_empty = true, root_folder_label = ":~" },
    filters = { custom = { "^.git$" } },
    on_attach = function(buf)
      local api = require("nvim-tree.api")
      api.config.mappings.default_on_attach(buf)
      -- free keys used globally: window nav and tab switching
      for _, key in ipairs({ "<C-k>", "H", "L" }) do
        pcall(vim.keymap.del, "n", key, { buffer = buf })
      end
      vim.keymap.set("n", "<Tab>", function()
        local node = api.tree.get_node_under_cursor()
        if node and node.type == "directory" then
          api.node.open.edit()
        end
      end, { buffer = buf, desc = "Toggle directory" })
    end,
  },
}
