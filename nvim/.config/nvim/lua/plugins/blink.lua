-- blink.lua — completion (blink.cmp), modern successor to nvim-cmp
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "default", -- <C-space> show, <C-n>/<C-p> next/prev, <CR> accept, <C-e> hide, <C-k> docs toggle
        -- you can switch to "super-tab" if you prefer tab to accept
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 400, window = { border = "rounded" } },
        menu = { border = "rounded" },
        ghost_text = { enabled = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      snippets = { preset = "default" }, -- uses friendly-snippets via blink's snippet engine
      fuzzy = { implementation = "prefer_rust_with_warning" },
      signature = { enabled = true, window = { border = "rounded" } },
    },
    opts_extend = { "sources.default" },
  },
}
