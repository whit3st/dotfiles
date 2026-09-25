-- ftplugin/java.lua — jdtls launch via nvim-jdtls (KISS, config as code)
-- This is the recommended way per nvim-jdtls docs: start_or_attach per buffer
local ok, jdtls = pcall(require, "jdtls")
if not ok then
  vim.notify("nvim-jdtls not found", vim.log.levels.WARN)
  return
end

-- Find root markers (Gradle/Maven/Git)
local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" or root_dir == nil then
  -- single file support: use file's dir
  root_dir = vim.fn.expand("%:p:h")
end

-- Mason's jdtls binary wraps the java launch
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
local jdtls_cmd = vim.fn.executable(mason_bin) == 1 and mason_bin or "jdtls"

-- Workspace per project (isolated)
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
if project_name == "" then project_name = "default" end
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name

-- Ensure workspace dir exists
vim.fn.mkdir(workspace_dir, "p")

-- Capabilities from blink.cmp if present
local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then capabilities = blink.get_lsp_capabilities(capabilities) end
-- Add extended capabilities for jdtls
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local config = {
  cmd = { jdtls_cmd, "-data", workspace_dir },
  root_dir = root_dir,
  capabilities = capabilities,
  settings = {
    java = {
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      references = { includeDecompiledSources = true },
      format = { enabled = true },
      -- Gradle/Kotlin support: jdtls detects gradle via root_markers
      configuration = {
        updateBuildConfiguration = "interactive",
        -- Runtimes: will auto-detect JAVA_HOME; you can pin here if needed
        -- runtimes = {
        --   { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk" },
        --   { name = "JavaSE-26", path = "/usr/lib/jvm/java-26-openjdk" },
        -- },
      },
    },
  },
  init_options = {
    bundles = {},
    extendedClientCapabilities = extendedClientCapabilities,
  },
  -- completion / snippet handled by blink
}

-- Start or attach
jdtls.start_or_attach(config)

-- Keymaps specific to jdtls buffer (LspAttach already covers generic)
-- Extra jdtls commands available: :JdtUpdateConfig, etc. via jdtls.setup.add_commands()
vim.api.nvim_create_autocmd("LspAttach", {
  buffer = 0,
  once = true,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "jdtls" then return end
    -- ensure commands when build changes
    pcall(require("jdtls").setup.add_commands)
    -- optional: dap setup if nvim-dap installed
    -- pcall(require("jdtls").setup_dap, { hotcodereplace = "auto" })
    -- pcall(require("jdtls.dap").setup_dap_main_class_configs)
  end,
})
