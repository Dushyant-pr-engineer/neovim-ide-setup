return {
    {
        "neovim/nvim-lspconfig", -- now just supplies default per-server configs, no .setup{} calls
    },
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        opts = {
            ensure_installed = {
                "intelephense", -- PHP
                -- "ts_ls", -- JS/TS (disabled: initialization issues — TODO: debug TypeScript setup)
                "gopls", -- Go
                "pyright", -- Python (types/completion)
                "ruff", -- Python (fast linting + formatting, native LSP mode)
                "terraformls", -- Terraform
                "bashls", -- Shell
                "yamlls", -- YAML
                "jsonls", -- JSON
                "lua_ls", -- Lua (for editing this very config)
            },
            -- automatic_enable defaults to true: installed servers get
            -- vim.lsp.enable()'d for you automatically.
        },
    },
}
