-- dired: directories are buffers you edit
return {
  "stevearc/oil.nvim",
  lazy = false, -- so `nvim .` and :e dir/ open oil
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    view_options = { show_hidden = true },
    use_default_keymaps = false,
    keymaps = {
      ["g?"] = { "actions.show_help", mode = "n" },
      ["<CR>"] = "actions.select",
      ["<C-p>"] = "actions.preview",
      ["q"] = { "actions.close", mode = "n" },
      ["<C-c>"] = { "actions.close", mode = "n" },
      ["-"] = { "actions.parent", mode = "n" },
      ["_"] = { "actions.open_cwd", mode = "n" },
      ["`"] = { "actions.cd", mode = "n" },
      ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
      ["gs"] = { "actions.change_sort", mode = "n" },
      ["gx"] = "actions.open_external",
      ["g."] = { "actions.toggle_hidden", mode = "n" },
      ["g\\"] = { "actions.toggle_trash", mode = "n" },
      ["gr"] = "actions.refresh",
    },
  },
}
