-- eglot: servers come from PATH (no mason); unavailable ones are skipped
local servers = {
  "gopls",
  "tsc", -- TypeScript 7's native server (tsc --lsp); stands aside for Deno projects
  "denols",
  "lua_ls",
  "rust_analyzer",
  "nil_ls",
  "wgsl_analyzer",
  "jdtls",
}

-- servers whose lspconfig cmd is a function, so the binary can't be read from it
local binaries = { tsc = "tsc", jdtls = "jdtls" }

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
        },
      },
    })
    -- only attach denols inside Deno projects
    vim.lsp.config("denols", {
      root_dir = function(buf, on_dir)
        local root = vim.fs.root(buf, { "deno.json", "deno.jsonc" })
        if root then
          on_dir(root)
        end
      end,
    })
    if vim.env.JAVA_HOME then
      vim.lsp.config("jdtls", {
        settings = {
          java = {
            configuration = {
              runtimes = { { name = "JavaSE-21", path = vim.env.JAVA_HOME, default = true } },
            },
          },
        },
      })
    end

    for _, name in ipairs(servers) do
      local cmd = (vim.lsp.config[name] or {}).cmd
      local bin = type(cmd) == "table" and cmd[1] or binaries[name]
      if bin and vim.fn.executable(bin) == 1 then
        vim.lsp.enable(name)
      end
    end
  end,
}
