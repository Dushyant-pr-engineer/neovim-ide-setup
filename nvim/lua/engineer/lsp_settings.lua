-- Per-server customization via the native vim.lsp.config() API (merges with
-- nvim-lspconfig's defaults). mason-lspconfig's automatic_enable handles the
-- vim.lsp.enable() call for every server listed in plugins/lsp.lua.

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            telemetry = { enable = false },
        },
    },
})

vim.lsp.config("intelephense", {
    root_markers = { "composer.json", ".git" },
    -- Optional, once you have a license: reads ~/intelephense/licence.txt (note British spelling)
    -- init_options = {
    --     licenceKey = (function()
    --         local f = io.open(os.getenv("HOME") .. "/intelephense/licence.txt", "rb")
    --         if not f then return nil end
    --         local key = f:read("*a"):gsub("%s+", "")
    --         f:close()
    --         return key
    --     end)(),
    -- },
})

vim.lsp.config("gopls", {
    settings = {
        gopls = {
            staticcheck = true,
            gofumpt = true,
        },
    },
})
