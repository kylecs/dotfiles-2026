local parsers = {
  "bash",
  "css",
  "diff",
  "go",
  "gomod",
  "gosum",
  "html",
  "java",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "nix",
  "nu",
  "query",
  "regex",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "wgsl",
  "yaml",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install(parsers)
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("kyle.treesitter", { clear = true }),
      callback = function(ev)
        if not pcall(vim.treesitter.start, ev.buf) then
          return
        end
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
