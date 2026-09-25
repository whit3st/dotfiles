-- extra.lua — small extras: persistence, mini, etc (keep minimal)
return {
  -- markdown render — GitHub-Flavored Markdown rendered in-buffer, toggleable
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Toggle markdown render" },
      { "<leader>uM", "<cmd>RenderMarkdown disable<cr>", ft = "markdown", desc = "Disable markdown render" },
    },
  },
}
