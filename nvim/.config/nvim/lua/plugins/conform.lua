-- conform.lua — formatting (conform.nvim) + linting (nvim-lint)
return {
  -- formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>f", function() require("conform").format({ async = true, lsp_fallback = true }) end, mode = { "n", "v" }, desc = "Format" },
      { "<leader>cF", function() require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 }) end, mode = { "n", "v" }, desc = "Format injected" },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- disable autoformat for files in node_modules, or if global var set
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match("/node_modules/") then return end
        return { timeout_ms = 2000, lsp_fallback = true }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        -- JS/TS/web — prettierd preferred, fallback to prettier
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        astro = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettierd", "prettier", stop_after_first = true },
        vue = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        graphql = { "prettierd", "prettier", stop_after_first = true },
        -- JVM
        java = { "google-java-format" }, -- or google_java_format; mason name is google-java-format
        kotlin = { "ktlint" },
        groovy = { "npm-groovy-lint" }, -- optional
        -- gradle via ktlint/groovy
        -- generic
        sh = { "shfmt" },
        toml = { "taplo" },
      },
      formatters = {
        -- use project-local prettier if available (conform handles it); otherwise mason's
        prettierd = {
          -- only if needed; keep default
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      -- commands to toggle format on save
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then vim.b.disable_autoformat = true else vim.g.disable_autoformat = true end
      end, { desc = "Disable autoformat", bang = true })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Enable autoformat" })
    end,
  },

  -- linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        astro = { "eslint_d" },
        svelte = { "eslint_d" },
        -- kotlin/java via ktlint? mostly via LSP; keep minimal
        -- yaml/json lint via lsp instead
      }
      -- custom: try eslint_d, fallback to eslint if not installed
      local eslint = lint.linters.eslint_d
      if eslint then
        -- use flat config aware: eslint_d handles both
      end
      local group = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = group,
        callback = function()
          -- only lint if linter exists for ft
          local ft = vim.bo.filetype
          if lint.linters_by_ft[ft] then lint.try_lint() end
        end,
      })
    end,
  },
}
