-- lsp.lua — LSP + Mason + nvim-jdtls + kotlin.nvim
return {
  -- mason: installs LSPs, formatters, linters
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog", "MasonUninstallAll" },
    keys = { { "<leader>m", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded", icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } },
    },
  },

  -- mason-lspconfig: bridges mason <-> lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        -- TS / web stack (your main)
        "ts_ls", -- typescript-language-server
        "astro",
        "eslint",
        "html",
        "cssls",
        "jsonls",
        "yamlls",
        "tailwindcss",
        "marksman", -- markdown
        "lua_ls",
        -- JVM stack
        "jdtls",
        "kotlin_lsp", -- via kotlin.nvim, but ensure binary exists
        "gradle_ls",
      },
      automatic_enable = {
        exclude = {
          "jdtls", -- handled by nvim-jdtls ftplugin
          "kotlin_lsp", -- handled by kotlin.nvim
        },
      },
    },
  },

  -- tool installer — ensures formatters/linters are present
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- formatters
        "prettierd",
        "prettier",
        "stylua",
        "shfmt",
        "google-java-format",
        "ktlint",
        -- linters
        "eslint_d",
        -- extra
        "taplo",
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  -- main lspconfig — server configs
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      -- lua dev
      { "folke/lazydev.nvim", ft = "lua", opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } } },
    },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        severity_sort = true,
      },
      inlay_hints = { enabled = true },
      codelens = { enabled = false },
    },
    config = function(_, opts)
      -- capabilities from blink.cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_blink, blink = pcall(require, "blink.cmp")
      if has_blink then capabilities = blink.get_lsp_capabilities(capabilities) end
      -- also add foldingRange for nvim-ufo if ever used
      capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

      -- base on_attach is now via LspAttach autocmd in autocmds.lua; keep server-specific tweaks here

      -- server setups — nvim 0.11+ uses vim.lsp.config + vim.lsp.enable; we also support legacy lspconfig.setup for compat
      -- helper to setup via lspconfig if vim.lsp.config not present
      local lspconfig = require("lspconfig")

      local function setup(server, config)
        config = config or {}
        config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
        -- Prefer new API if available (nvim 0.11+)
        if vim.lsp.config then
          -- Only set if not already configured
          pcall(vim.lsp.config, server, config)
          vim.lsp.enable(server)
        else
          lspconfig[server].setup(config)
        end
      end

      -- Diagnostics signs already in options.lua

      -- TypeScript — ts_ls (typescript-language-server)
      -- For monorepos, search up for tsconfig.json/package.json
      setup("ts_ls", {
        init_options = { hostInfo = "neovim" },
        settings = {
          completions = { completeFunctionCalls = true },
        },
        -- Avoid attaching to deno projects
        root_dir = function(fname)
          local util = require("lspconfig.util")
          local deno_root = util.root_pattern("deno.json", "deno.jsonc", "deno.lock")(fname)
          if deno_root then return nil end
          return util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git")(fname)
        end,
        single_file_support = false,
      })

      -- Astro
      setup("astro", {
        init_options = { typescript = {} },
      })

      -- ESLint — fix on save via conform? let eslint handle diagnostics only
      setup("eslint", {
        settings = { workingDirectories = { mode = "auto" } },
        -- only attach if eslint config exists; lspconfig already handles root_pattern
      })

      -- HTML/CSS/JSON/YAML — for astro + TS projects
      setup("html", {})
      setup("cssls", {})
      setup("tailwindcss", {
        -- tailwindcss root: tailwind.config.*
        root_dir = require("lspconfig.util").root_pattern("tailwind.config.js", "tailwind.config.cjs", "tailwind.config.ts", "postcss.config.js", ".git"),
      })

      setup("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore") and require("schemastore").json.schemas() or nil,
            validate = { enable = true },
          },
        },
      })

      setup("yamlls", {
        settings = {
          yaml = {
            keyOrdering = false,
          },
        },
      })

      setup("marksman", {})

      -- Lua
      setup("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            codeLens = { enable = true },
            completion = { callSnippet = "Replace" },
            hint = { enable = true },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- Gradle — gradle-language-server (if available)
      -- It provides completions for build.gradle; for Kotlin DSL (build.gradle.kts) kotlin_lsp handles it
      pcall(setup, "gradle_ls", {})

      -- Bash / Docker — lightweight helpers
      pcall(setup, "bashls", {})
      pcall(setup, "dockerls", {})

      -- Note: jdtls and kotlin_lsp are deliberately NOT setup here
      -- jdtls: see ftplugin/java.lua + lua/plugins/jdtls.lua (nvim-jdtls)
      -- kotlin: see lua/plugins/kotlin.lua (kotlin.nvim)
    end,
  },

  -- Kotlin — kotlin.nvim (wraps kotlin-lsp, the official JetBrains Kotlin LSP)
  -- Provides jvm_args, build_tool, inlay hints, go-to-def etc.
  {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = { "kotlin" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "stevearc/oil.nvim",
      "folke/trouble.nvim",
    },
    opts = {
      -- Uses Mason's kotlin-lsp automatically; no JDK needed (bundled JRE v261+)
      -- Forward JVM args via IJ_JAVA_OPTIONS; example -Xmx
      jvm_args = {}, -- e.g. { "-Xmx4g" }
      -- build_tool = "gradle" -- or "maven", auto-detected if nil
    },
    config = function(_, opts)
      require("kotlin").setup(opts)
    end,
  },

  -- Java — nvim-jdtls
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "mason-org/mason.nvim" },
  },

  -- schemastore for json/yaml schemas (optional, lazy)
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
}
