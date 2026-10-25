local function in_deno_project(_, ctx)
  return vim.fs.root(ctx.dirname, { "deno.json", "deno.jsonc" }) ~= nil
end

return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "deno_fmt" },
      javascriptreact = { "deno_fmt" },
      typescript = { "deno_fmt" },
      typescriptreact = { "deno_fmt" },
    },
    -- deno_fmt only in Deno projects; otherwise fall back to the LSP formatter
    formatters = { deno_fmt = { condition = in_deno_project } },
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = { timeout_ms = 1000 },
  },
}
