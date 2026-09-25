-- keymaps.lua — global keymaps (plugin-specific keymaps live in plugin specs)
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better escape? keep default, terminal handled in autocmds

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Save / quit — keep minimal, no <C-s> hijack in terminal? provide both
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all" })

-- Window navigation — matches tmux / i3 style
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize with arrows
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffers
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New buffer" })

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Keep visual indent
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Better J (keep cursor)
map("n", "J", "mzJ`z", { desc = "Join lines" })

-- Center after moves
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)

-- Quickfix
map("n", "[q", "<cmd>cprev<cr>zz", { desc = "Prev quickfix" })
map("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix" })

-- Diagnostic jumps (native)
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Toggle utils (fallbacks, plugins may override)
map("n", "<leader>us", function()
  vim.wo.spell = not vim.wo.spell
end, { desc = "Toggle spell" })
map("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle wrap" })
map("n", "<leader>ul", function()
  local enabled = vim.wo.relativenumber
  vim.wo.relativenumber = not enabled
  vim.wo.number = true
end, { desc = "Toggle relative number" })

-- Terminal — double <Esc> to go normal
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter normal mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- Explorer fallback (oil will override)
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "Explorer" })

-- Lazy / Mason
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Mason" })

-- Cheatsheet — curated modal (Telescope-style), :Cheatsheet for float overview
map("n", "<leader>ch", function() require("config.cheatsheet").show() end, { desc = "Cheatsheet (curated)" })
map("n", "<leader>cH", function() require("config.cheatsheet").float() end, { desc = "Cheatsheet (full view)" })
vim.api.nvim_create_user_command("Cheatsheet", function() require("config.cheatsheet").float() end, { desc = "Open curated cheatsheet float" })
vim.api.nvim_create_user_command("CheatsheetTelescope", function() require("config.cheatsheet").telescope() end, { desc = "Open cheatsheet telescope picker" })
