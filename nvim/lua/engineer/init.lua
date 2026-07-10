require("engineer.options")
require("engineer.remaps")
require("engineer.lsp_keymaps")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("engineer.plugins", {
    change_detection = { notify = false },
    rocks = { enabled = false },
})

-- Per-server LSP settings that must be configured before/independent of
-- plugin load order (mason-lspconfig auto-enables the servers themselves).
require("engineer.lsp_settings")
