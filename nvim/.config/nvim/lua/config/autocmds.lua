-- autocmds.lua — autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yank
augroup("yank_highlight", { clear = true })
autocmd("TextYankPost", {
  group = "yank_highlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
  desc = "Highlight on yank",
})

-- Restore cursor position
augroup("restore_cursor", { clear = true })
autocmd("BufReadPost", {
  group = "restore_cursor",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Restore cursor",
})

-- Auto create dir when saving
augroup("auto_create_dir", { clear = true })
autocmd("BufWritePre", {
  group = "auto_create_dir",
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  desc = "Auto create dir",
})

-- Close some filetypes with <q>
augroup("close_with_q", { clear = true })
autocmd("FileType", {
  group = "close_with_q",
  pattern = {
    "help", "lspinfo", "man", "notify", "qf", "query",
    "spectre_panel", "startuptime", "tsplayground", "neotest-output",
    "checkhealth", "gitsigns-blame", "grug-far", "fugitive",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, desc = "Close" })
  end,
  desc = "Close with q",
})

-- Wrap and spell for text
augroup("wrap_spell", { clear = true })
autocmd("FileType", {
  group = "wrap_spell",
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
  desc = "Wrap+spell for text",
})

-- Checktime on focus
augroup("checktime", { clear = true })
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = "checktime",
  command = "checktime",
  desc = "Checktime",
})

-- Resize splits on VimResized
augroup("resize_splits", { clear = true })
autocmd("VimResized", {
  group = "resize_splits",
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
  desc = "Resize splits",
})

-- Terminal: start insert, no numbers
augroup("terminal_settings", { clear = true })
autocmd("TermOpen", {
  group = "terminal_settings",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
  desc = "Terminal setup",
})

-- Auto equalize after terminal close
autocmd("TermClose", {
  group = "terminal_settings",
  callback = function()
    if vim.v.event.status == 0 then
      vim.api.nvim_buf_delete(0, {})
    end
  end,
})

-- LSP keymaps — modern LspAttach (replaces on_attach)
augroup("lsp_attach", { clear = true })
autocmd("LspAttach", {
  group = "lsp_attach",
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("gd", vim.lsp.buf.definition, "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("gr", vim.lsp.buf.references, "References")
    map("gI", vim.lsp.buf.implementation, "Goto implementation")
    map("gy", vim.lsp.buf.type_definition, "Type definition")
    map("K", vim.lsp.buf.hover, "Hover")
    map("gK", vim.lsp.buf.signature_help, "Signature help")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>cr", vim.lsp.buf.rename, "Rename")
    map("<leader>cA", function()
      vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
    end, "Source action")

    -- inlay hints toggle (neovim 0.10+)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      map("<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "Toggle inlay hints")
    end

    -- document highlight
    if client and client:supports_method("textDocument/documentHighlight") then
      local hl_group = augroup("lsp_document_highlight_" .. event.buf, { clear = true })
      autocmd({ "CursorHold", "CursorHoldI" }, {
        group = hl_group,
        buffer = event.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = hl_group,
        buffer = event.buf,
        callback = vim.lsp.buf.clear_references,
      })
      autocmd("LspDetach", {
        group = augroup("lsp_detach_" .. event.buf, { clear = true }),
        buffer = event.buf,
        callback = function()
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = hl_group, buffer = event.buf })
        end,
      })
    end
  end,
  desc = "LSP attach keymaps",
})

-- Auto toggle hlsearch
augroup("auto_hlsearch", { clear = true })
autocmd("CmdlineEnter", {
  group = "auto_hlsearch",
  callback = function()
    vim.opt.hlsearch = true
  end,
})
autocmd("CmdlineLeave", {
  group = "auto_hlsearch",
  callback = function()
    -- no immediate off; <Esc> clears manually
  end,
})
