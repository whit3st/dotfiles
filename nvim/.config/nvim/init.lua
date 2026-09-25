-- init.lua — entry point
-- Simple, clean terminal IDE for TypeScript, Astro, Kotlin, Java, Gradle, Lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
