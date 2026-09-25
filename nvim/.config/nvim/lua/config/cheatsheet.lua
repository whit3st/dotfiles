-- cheatsheet.lua — curated modal for most-used shortcuts (Telescope-style)
-- Edit the `entries` table to customize. Each entry: { keys, desc, category }
-- <leader>ch opens Telescope picker; :Cheatsheet opens floating window.

local M = {}

-- Curated, most-used shortcuts (grouped by category)
-- Keep this short — only the 80/20 you actually need daily.
M.entries = {
  -- Find / Telescope
  { keys = "<leader>ff", desc = "Find files", category = "Find" },
  { keys = "<leader>fg", desc = "Live grep", category = "Find" },
  { keys = "<leader>fb", desc = "Buffers", category = "Find" },
  { keys = "<leader>fr", desc = "Recent files", category = "Find" },
  { keys = "<leader>gg", desc = "Git status (changed files)", category = "Find / Git" },
  { keys = "<leader>fd", desc = "Diagnostics", category = "Find" },
  { keys = "<leader>fs", desc = "Document symbols", category = "Find" },

  -- File explorer (Oil) — vscode-like git colors via oil-git
  { keys = "<leader>e", desc = "Oil explorer (git highlights)", category = "Files" },
  { keys = "-", desc = "Oil parent", category = "Files" },
  { keys = "g?", desc = "Oil help", category = "Files" },
  { keys = "g.", desc = "Toggle hidden", category = "Files" },

  -- LSP / Code
  { keys = "gd", desc = "Goto definition", category = "Code" },
  { keys = "gr", desc = "References (Telescope)", category = "Code" },
  { keys = "K", desc = "Hover", category = "Code" },
  { keys = "<leader>ca", desc = "Code action", category = "Code" },
  { keys = "<leader>cr", desc = "Rename", category = "Code" },
  { keys = "<leader>f", desc = "Format", category = "Code" },
  { keys = "[d / ]d", desc = "Prev/Next diagnostic", category = "Code" },
  { keys = "<leader>xx", desc = "Trouble diagnostics", category = "Code" },

  -- Git (gitsigns + oil-git)
  { keys = "]h / [h", desc = "Next/Prev hunk", category = "Git" },
  { keys = "<leader>gs", desc = "Stage hunk", category = "Git" },
  { keys = "<leader>gp", desc = "Preview hunk", category = "Git" },
  { keys = "<leader>gb", desc = "Blame line", category = "Git" },
  { keys = "<leader>gg", desc = "Git status (Telescope)", category = "Git" },

  -- Buffers / Windows
  { keys = "<C-h/j/k/l>", desc = "Window nav", category = "Nav" },
  { keys = "[b / ]b", desc = "Prev/Next buffer", category = "Nav" },
  { keys = "<leader>bd", desc = "Delete buffer", category = "Nav" },

  -- Toggles / UI
  { keys = "<leader>us", desc = "Toggle spell", category = "UI" },
  { keys = "<leader>uw", desc = "Toggle wrap", category = "UI" },
  { keys = "<leader>l", desc = "Lazy", category = "UI" },
  { keys = "<leader>m", desc = "Mason", category = "UI" },
  { keys = "<leader>ch", desc = "This cheatsheet", category = "UI" },
  { keys = "<leader>?", desc = "Which-key (all)", category = "UI" },
  { keys = "<leader>fk", desc = "All keymaps (Telescope)", category = "UI" },
}

-- Telescope picker — fuzzy, like vscode command palette
function M.telescope()
  local has_telescope, telescope = pcall(require, "telescope")
  if not has_telescope then
    vim.notify("Telescope not found, falling back to float", vim.log.levels.WARN)
    return M.float()
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- format: "category | keys -> desc"
  local make_display = function(entry)
    local e = entry.value
    -- pad category (12) and keys (16) for alignment
    return string.format("%-12s  %-16s  %s", e.category, e.keys, e.desc)
  end

  pickers.new({}, {
    prompt_title = "Cheatsheet — most used (edit lua/config/cheatsheet.lua)",
    finder = finders.new_table({
      results = M.entries,
      entry_maker = function(e)
        return {
          value = e,
          display = make_display,
          ordinal = e.category .. " " .. e.keys .. " " .. e.desc,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if not selection then return end
        local keys = selection.value.keys
        -- If keys looks like a real mapping (not "a / b"), feed it.
        -- For "a / b" entries, just notify.
        if keys:match("/") and not keys:match("<leader>") then
          vim.notify(selection.value.desc .. ": " .. keys, vim.log.levels.INFO)
          return
        end
        -- For entries like "<leader>ff", feed keys to trigger the mapping
        -- Use nvim_feedkeys with termcodes, remap = true ("m" = remap)
        local term = vim.api.nvim_replace_termcodes(keys, true, false, true)
        vim.api.nvim_feedkeys(term, "m", false)
        -- also echo desc
        vim.defer_fn(function()
          vim.notify("→ " .. selection.value.desc, vim.log.levels.INFO)
        end, 50)
      end)
      return true
    end,
  }):find()
end

-- Floating window — full overview, no fuzzy, grouped
function M.float()
  local lines = {}
  local hl_lines = {} -- {lnum, col_start, col_end, hl_group}

  table.insert(lines, " Cheatsheet — most used  (edit lua/config/cheatsheet.lua to customize) ")
  table.insert(lines, "")

  -- group by category
  local by_cat = {}
  local order = {}
  for _, e in ipairs(M.entries) do
    if not by_cat[e.category] then
      by_cat[e.category] = {}
      table.insert(order, e.category)
    end
    table.insert(by_cat[e.category], e)
  end

  for _, cat in ipairs(order) do
    table.insert(lines, " " .. cat)
    -- add underline hl
    table.insert(hl_lines, { #lines, 1, 1 + #cat + 1, "Title" })
    for _, e in ipairs(by_cat[cat]) do
      local line = string.format("  %-16s  %s", e.keys, e.desc)
      table.insert(lines, line)
      table.insert(hl_lines, { #lines, 2, 2 + #e.keys + 1, "Keyword" })
    end
    table.insert(lines, "")
  end

  table.insert(lines, " q / <Esc> to close  •  <leader>fk = all keymaps  •  <leader>? = which-key ")
  table.insert(hl_lines, { #lines, 1, -1, "Comment" })

  -- create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "cheatsheet"
  vim.bo[buf].bufhidden = "wipe"

  -- apply highlights
  local ns = vim.api.nvim_create_namespace("cheatsheet")
  for _, hl in ipairs(hl_lines) do
    local lnum, cs, ce, group = hl[1], hl[2], hl[3], hl[4]
    if ce == -1 then ce = #lines[lnum] end
    vim.api.nvim_buf_set_extmark(buf, ns, lnum - 1, cs - 1, { end_col = ce - 1, hl_group = group })
  end

  -- size: 60% width, 70% height, centered
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.75)
  width = math.max(60, math.min(width, 80))
  height = math.min(height, #lines + 2)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Cheatsheet ",
    title_pos = "center",
    noautocmd = true,
  })
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false
  vim.wo[win].conceallevel = 0

  -- close maps
  local close = function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, silent = true, desc = "Close cheatsheet" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, silent = true })
  vim.keymap.set("n", "<C-c>", close, { buffer = buf, silent = true })
  -- also allow <leader>ch to close if pressed again
  vim.keymap.set("n", "<leader>ch", close, { buffer = buf, silent = true })
end

-- unified entry: Telescope picker is default ("modal like telescope")
function M.show()
  -- prefer telescope picker for fuzzy modal
  if pcall(require, "telescope") then
    return M.telescope()
  else
    return M.float()
  end
end

return M
