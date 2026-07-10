return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                php = { "php_cs_fixer" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                go = { "goimports", "gofumpt" },
                python = { "ruff_format" },
                terraform = { "terraform_fmt" },
                sh = { "shfmt" },
                yaml = { "prettier" },
                json = { "prettier" },
                markdown = { "prettier" },
                lua = { "stylua" },
            },
            format_on_save = { timeout_ms = 500, lsp_fallback = true },
        },
    },
    {
        -- Auto-installs the CLI formatter binaries above via Mason,
        -- so you don't need to `npm install -g prettier` etc. by hand.
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                "php-cs-fixer", "prettier", "goimports", "gofumpt",
                "shfmt", "stylua", "shellcheck", "eslint_d",
            },
        },
    },
}
