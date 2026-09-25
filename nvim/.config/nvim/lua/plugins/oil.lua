-- oil.lua — buffer-based file explorer (edit filesystem like buffer)
return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- want it early for netrw replacement
    keys = {
      { "<leader>e", function() require("oil").open() end, desc = "Oil explorer" },
      { "<leader>E", function() require("oil").open(vim.fn.getcwd()) end, desc = "Oil cwd" },
      { "-", function() require("oil").open() end, desc = "Oil parent" },
    },
    opts = {
      default_file_explorer = true,
      columns = { "icon" },
      win_options = { wrap = false, signcolumn = "yes", cursorcolumn = false, foldcolumn = "0", spell = false, list = false, conceallevel = 3, concealcursor = "nvic" },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      view_options = { show_hidden = true, is_hidden_file = function(name) return vim.startswith(name, ".") end, is_always_hidden = function(name) return name == ".." or name == ".git" end },
      float = { padding = 2, max_width = 100, max_height = 30, border = "rounded" },
      preview = { max_width = 0.9, min_width = 40, width = nil, max_height = 0.9, min_height = 5, height = nil, border = "rounded" },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
      },
      use_default_keymaps = true,
    },
  },
  -- git highlights in oil — vscode-like coloring for changed files (green untracked, yellow modified etc.)
  -- malewicz1337/oil-git.nvim is maintained fork of benomahony/oil-git.nvim, async, zero lag
  {
    "malewicz1337/oil-git.nvim",
    dependencies = { "stevearc/oil.nvim" },
    lazy = false,
    -- no setup required, but we pass opts to tune vscode-like feel
    opts = {
      debounce_ms = 50,
      show_file_highlights = true,
      show_directory_highlights = true,
      show_file_symbols = true,
      show_directory_symbols = true,
      show_ignored_files = false,
      show_ignored_directories = false,
      symbol_position = "eol", -- "eol" shows + ~ ? at end of line, "signcolumn" alternative
      symbols = {
        file = {
          added = " +",
          modified = " ~",
          renamed = " →",
          deleted = " D",
          copied = " C",
          conflict = " !",
          untracked = " ?",
          ignored = " o",
        },
        directory = {
          added = " *",
          modified = " *",
          renamed = " *",
          deleted = " *",
          copied = " *",
          conflict = " !",
          untracked = " *",
          ignored = " o",
        },
      },
      highlights = {
        OilGitAdded = { fg = "#a6e3a1" },            -- green (staged new)
        OilGitModifiedStaged = { fg = "#f9e2af" },   -- yellow
        OilGitModifiedUnstaged = { fg = "#e5c890" }, -- gold
        OilGitRenamed = { fg = "#cba6f7" },          -- purple
        OilGitDeleted = { fg = "#f38ba8" },          -- red
        OilGitUntracked = { fg = "#89b4fa" },        -- blue
        OilGitIgnored = { fg = "#6c7086" },          -- gray
      },
    },
    config = function(_, opts)
      require("oil-git").setup(opts)
    end,
  },
}
