-- treesitter.lua — syntax highlighting and parsing (nvim-treesitter rewrite, Neovim 0.12+)
return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    config = function()
      -- install parsers for your main languages
      local ensure = {
        -- core
        "bash", "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
        -- web / TS stack
        "typescript", "tsx", "javascript", "jsdoc", "json", "html", "css", "scss",
        "astro", "yaml", "toml", "regex",
        -- JVM stack
        "java", "kotlin", "groovy",
        -- other handy
        "dockerfile", "gitignore", "gitcommit", "diff", "sql", "graphql", "http",
        "python",
      }

      require("nvim-treesitter").setup({
        -- install_dir = vim.fn.stdpath("data") .. "/site", -- default
      })

      -- install missing parsers async (no-op if already installed)
      -- use pcall and schedule to avoid blocking startup
      vim.schedule(function()
        local ok, ts = pcall(require, "nvim-treesitter")
        if ok then pcall(function() ts.install(ensure):wait(300000) end) end
      end)

      -- enable treesitter highlighting + folds + indent via FileType autocmd
      -- (new API: vim.treesitter.start() instead of configs.setup highlight.enable)
      local group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          -- try to start treesitter for any filetype; if parser missing, pcall fails silently
          pcall(vim.treesitter.start, args.buf)
          -- folds
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
          -- indent (experimental, but nice)
          pcall(function()
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end)
        end,
      })

      -- also re-apply for already-open buffers (e.g., after :TSUpdate)
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              local ft = vim.bo[buf].filetype
              if ft ~= "" then pcall(vim.treesitter.start, buf) end
            end
          end
        end,
      })
    end,
  },

  -- autotag for html/tsx/astro — still works with new treesitter via separate autocmd
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter" },
    opts = {},
  },

  -- context-aware commenting
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
  },

  -- textobjects — note: this plugin still expects old configs API, keep it lazy and optional
  -- If you need textobjects, ensure branch main supports it; otherwise disable for now.
  -- Kept disabled to avoid breaking rewrite:
  -- {
  --   "nvim-treesitter/nvim-treesitter-textobjects",
  --   branch = "main",
  --   event = "VeryLazy",
  -- },
}
