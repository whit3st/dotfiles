# Neovim — Terminal IDE

Simple, clean Neovim config (Neovim 0.12.5+) powered by `lazy.nvim`. Optimized for TypeScript, Astro, Kotlin, Java (Gradle), Lua.

> Stow package: `~/dotfiles/nvim/.config/nvim` → `~/.config/nvim` via `stow nvim` (from `~/dotfiles`).

## Install

```bash
# system deps (Arch)
sudo pacman -S neovim tree-sitter ripgrep fd fzf git curl xclip wl-clipboard

# or user-local (already done for you)
# ~/.local/bin/nvim  → 0.12.5, ~/.local/bin/fd, fzf, tree-sitter

# stow
cd ~/dotfiles
stow nvim

# first launch — lazy installs plugins
nvim
# :Lazy sync, :Mason, :TSUpdate
```

On first `nvim` launch, `lazy.nvim` clones plugins. `mason-tool-installer` auto-installs LSPs/formatters on `VeryLazy`. `nvim-treesitter` auto-installs parsers (typescript, astro, kotlin, java, etc.) in background (requires `tree-sitter` CLI + `gcc`).

## Plugin highlights

| Area | Plugin |
|---|---|
| manager | `folke/lazy.nvim` |
| theme | `folke/tokyonight.nvim` (fallback `catppuccin`) + `lualine`, `which-key`, `gitsigns`, `indent-blankline`, `noice`, `fidget` |
| finder | `telescope.nvim` + `fzf-native` + `ui-select` |
| files | `stevearc/oil.nvim` + `malewicz1337/oil-git.nvim` (vscode-like git colors) |
| syntax | `nvim-treesitter` (rewrite, main branch) — 30+ parsers |
| LSP | `mason.nvim` + `mason-lspconfig` + `nvim-lspconfig` + `mason-tool-installer` |
| Java | `mfussenegger/nvim-jdtls` (via `ftplugin/java.lua`, Mason `jdtls`) |
| Kotlin | `AlexandrosAlexiou/kotlin.nvim` (wraps `kotlin-lsp`, bundled JRE) |
| completion | `saghen/blink.cmp` v1.* (rust fuzzy, ghost text, snippets) |
| formatting | `stevearc/conform.nvim` (prettierd/prettier, stylua, ktlint, google-java-format, shfmt, taplo) |
| linting | `mfussenegger/nvim-lint` (eslint_d) |
| editing | `nvim-autopairs`, `Comment.nvim`, `mini.surround`, `mini.ai`, `flash.nvim`, `trouble.nvim`, `todo-comments.nvim` |

## LSPs

`mason-lspconfig` ensures (auto-install):

`ts_ls`, `astro`, `eslint`, `html`, `cssls`, `jsonls`, `yamlls`, `tailwindcss`, `marksman`, `lua_ls`, `jdtls`, `kotlin_lsp`, `gradle_ls`

Tools via `mason-tool-installer`:

`prettierd`, `prettier`, `stylua`, `shfmt`, `google-java-format`, `ktlint`, `eslint_d`, `taplo`

- **TypeScript/Astro**: `ts_ls` + `astro` + `eslint`. Root detection avoids Deno projects. Works with `tailwindcss` if `tailwind.config.*` present.
- **Kotlin**: `kotlin.nvim` starts `kotlin_lsp` (Mason `kotlin-lsp`). No JDK needed (bundled JRE). `jvm_args = {}` in `lua/plugins/lsp.lua` if you need `-Xmx`. See `:Kotlin*` commands.
- **Java**: `nvim-jdtls` via `ftplugin/java.lua`. Uses Mason `jdtls` binary, workspace per project in `~/.cache/jdtls/workspace/<project>`. Gradle/Maven detection via `gradlew`, `pom.xml`, etc. Run `:Mason` to verify `jdtls` installed.

Check attached clients: `:LspInfo` / `:checkhealth vim.lsp` / `:lua print(vim.inspect(vim.lsp.get_clients({bufnr=0})))`

## Keymaps

Leader is `<Space>`.

### General
- `<Esc>` clear hlsearch
- `<C-s>` / `<leader>w` save, `<leader>q/Q` quit
- `<C-h/j/k/l>` window nav, `<C-Up/Down/Left/Right>` resize
- `[b`/`]b` prev/next buffer, `<leader>bd` delete, `<leader>bn` new
- `<A-j/k>` move line, `J` join keep cursor, `<C-d/u>` center, `n/N` center
- `[q`/`]q` quickfix, `[d`/`]d` diagnostic jump, `<leader>cd` line diagnostics
- `<leader>us` spell, `<leader>uw` wrap, `<leader>ul` relative number
- `<leader>e` / `-` Oil explorer, `<leader>E` Oil cwd

### Find (Telescope)
- `<leader>ff` / `<leader>sf` files, `<leader>fg` / `<leader>sg` live grep, `<leader>fw`/`sw` word, `<leader>fb` buffers, `<leader>fh/sh` help, `<leader>fr` recent, `<leader>fk` keymaps, `<leader>fd` diagnostics, `<leader>fs` doc symbols, `<leader>fS` workspace symbols, `<leader>fc` commands
- Inside Telescope: `<C-j/k>` move, `<C-q>` send to qflist, `q` close

### LSP (on_attach, via `LspAttach` autocmd)
- `gd` definition (Telescope), `gD` declaration, `gr` references, `gI` implementation, `gy` type def
- `K` hover, `gK` signature
- `<leader>ca` code action, `<leader>cA` source action, `<leader>cr` rename (`<leader>rn` alias via which-key: `<leader>cr`/`rn`)
- `<leader>uh` toggle inlay hints
- `<leader>cd` line diagnostics, `[d`/`]d` jump

### Git (gitsigns)
- `]h`/`[h` next/prev hunk, `<leader>gs` stage hunk (visual), `<leader>gr` reset, `<leader>gS` stage buffer, `<leader>gu` undo stage, `<leader>gp` preview, `<leader>gb` blame, `<leader>gd` diffthis, `<leader>gD` diff ~

### Formatting / Diagnostics
- `<leader>f` format (conform, async), `<leader>cF` format injected, `:FormatDisable[!]` / `:FormatEnable` toggle autoformat
- `<leader>xx` Trouble diagnostics, `<leader>xX` buffer, `<leader>cs` symbols, `<leader>cl` lsp, `<leader>xL` loclist, `<leader>xQ` qflist
- `<leader>xt` Todo Trouble, `<leader>st` Todo Telescope, `]t`/`[t` next/prev todo

### Explorer / UI
- `<leader>e` Oil (git highlights via `oil-git`: green `+` staged, `~` modified, `?` untracked at EOL), `<leader>l` Lazy, `<leader>m` Mason
- `s` Flash jump, `S` Flash treesitter, `gsa/d/r` surround, `g?` Oil help
- `<leader>ch` **Cheatsheet** (curated, Telescope picker — most used), `<leader>cH` / `:Cheatsheet` full float, `<leader>?` which-key, `<leader>fk` all keymaps

## Commands

- `:Lazy` plugin manager, `:Mason` LSP installer, `:TSUpdate` update parsers, `:ConformInfo` formatters, `:LspInfo`
- `:FormatDisable` / `:FormatDisable!` (buffer) / `:FormatEnable`
- `:Cheatsheet` / `:CheatsheetTelescope` — curated shortcuts, edit `lua/config/cheatsheet.lua:1` to customize
- `:TodoTelescope`, `:Trouble`
- Kotlin: `:Kotlin*` (see `kotlin.nvim` docs)
- Java: `:Jdt*` (update config etc.)

## Notes

- Treesitter folding: `foldmethod=expr` + `foldexpr=vim.treesitter.foldexpr()`, open all folds by default (`foldenable=false`). Use `za`, `zc`, `zM` etc.
- Conform formats on save (except `node_modules`). Disable per-session: `:lua require("conform").setup({format_on_save=false})` or `:FormatDisable`.
- Blink `ghost_text` enabled, docs auto-show 400ms, `fuzzy = prefer_rust_with_warning` (auto-downloads prebuilt binary, falls back to Lua).
- If `tree-sitter` CLI missing: `cargo install tree-sitter-cli` or `~/.local/bin/tree-sitter` (already installed for you).

## Updating

- `:Lazy update` (check `lazy-lock.json` for pin), `:MasonUpdate` / `:MasonToolsUpdate`, `:TSUpdate`
- Neovim 0.12 handles LSP via `vim.lsp.config` + `vim.lsp.enable` (see `lua/plugins/lsp.lua`). For new server: add to `ensure_installed`, add `setup("server", {...})` in `lsp.lua`.

## Troubleshooting

- `:checkhealth`, `:checkhealth mason`, `:checkhealth vim.lsp`, `:Lazy profile`
- LSP not attaching: `:LspInfo`, check root markers (`tsconfig.json`, `package.json`, `gradlew`, `.git`), `:Mason` to ensure server installed.
- Treesitter: `:TSUpdate`, check `~/.local/share/nvim/site/parser` + `queries`.
- Slow startup: `:Lazy profile`.
