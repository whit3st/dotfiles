-- options.lua — vim options
local opt = vim.opt
local g = vim.g

-- leader already set in init.lua, but ensure early
g.mapleader = " "
g.maplocalleader = " "

-- UI
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.colorcolumn = "100"
opt.showmode = false
opt.showcmd = false
opt.laststatus = 3 -- global statusline
opt.winborder = "rounded" -- nvim 0.12 rounded borders by default
opt.pumheight = 10
opt.conceallevel = 0
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " " }

-- editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true
opt.linebreak = true
opt.smartcase = true
opt.ignorecase = true
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = "split"

-- files / undo
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.confirm = true

-- splits
opt.splitbelow = true
opt.splitright = true
opt.equalalways = false

-- timing
opt.timeoutlen = 300
opt.updatetime = 250
opt.ttimeoutlen = 10

-- clipboard — use system clipboard, requires xclip/wl-clipboard
opt.clipboard = "unnamedplus"

-- mouse
opt.mouse = "a"
opt.mousemoveevent = true

-- completion
opt.completeopt = "menu,menuone,noselect"
opt.wildmode = "longest:full,full"

-- folding — treesitter based, disabled by default (open all)
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false
opt.foldlevel = 99

-- spell (toggle with <leader>us)
opt.spelllang = { "en" }

-- disable unused providers (clean :checkhealth)
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0

-- neovim 0.12: enable editorconfig
g.editorconfig = true

-- diagnostics: nicer virtual text
vim.diagnostic.config({
  virtual_text = { spacing = 4, prefix = "●" },
  virtual_lines = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
})

-- disable netrw (we use oil.nvim)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
