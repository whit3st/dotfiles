-- telescope.lua — fuzzy finder
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", enabled = vim.fn.executable("make") == 1 },
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help" },
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Recent files" },
      { "<leader>fc", function() require("telescope.builtin").commands() end, desc = "Commands" },
      { "<leader>fk", function() require("telescope.builtin").keymaps() end, desc = "Keymaps" },
      { "<leader>fw", function() require("telescope.builtin").grep_string() end, desc = "Word under cursor" },
      { "<leader>fd", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics" },
      { "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Document symbols" },
      { "<leader>fS", function() require("telescope.builtin").lsp_workspace_symbols() end, desc = "Workspace symbols" },
      { "<leader>sg", function() require("telescope.builtin").live_grep() end, desc = "Search grep" },
      { "<leader>sf", function() require("telescope.builtin").find_files() end, desc = "Search files" },
      { "<leader>sw", function() require("telescope.builtin").grep_string() end, desc = "Search word" },
      { "<leader>sh", function() require("telescope.builtin").help_tags() end, desc = "Search help" },
      -- git (vscode-like source control)
      { "<leader>gg", function() require("telescope.builtin").git_status() end, desc = "Git status (changed files)" },
      { "<leader>gc", function() require("telescope.builtin").git_commits() end, desc = "Git commits" },
      { "<leader>gb", function() require("telescope.builtin").git_branches() end, desc = "Git branches" },
      { "gd", function() require("telescope.builtin").lsp_definitions() end, desc = "Goto definition (Telescope)" },
      { "gr", function() require("telescope.builtin").lsp_references() end, desc = "References (Telescope)" },
      { "gI", function() require("telescope.builtin").lsp_implementations() end, desc = "Implementation (Telescope)" },
      { "gy", function() require("telescope.builtin").lsp_type_definitions() end, desc = "Type definition (Telescope)" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = { horizontal = { prompt_position = "top", preview_width = 0.55 }, vertical = { mirror = false }, width = 0.87, height = 0.80, preview_cutoff = 120 },
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = {
              ["q"] = actions.close,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
            },
          },
          file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/", ".gradle/", "target/" },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case", "--hidden", "--glob=!.git/*",
          },
        },
        pickers = {
          find_files = { hidden = true, find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" } },
        },
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },
}
