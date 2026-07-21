return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters = {
                -- Same fixer + standard as policyr's pre-commit hook
                -- (.git/hooks/pre-commit runs phpcs --standard=phpcs.xml;
                -- phpcbf is its auto-fix counterpart), so formatting here
                -- matches what actually gates commits for the team.
                phpcbf = {
                    prepend_args = { "--standard=phpcs.xml", "-d", "memory_limit=512M" },
                    cwd = function(_, ctx)
                        return vim.fs.root(ctx.dirname, { "composer.json" })
                    end,
                },
            },
            formatters_by_ft = {
                php = { "phpcbf" },
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
                -- "phpcs" is the mason package name; it bundles both the
                -- phpcs and phpcbf binaries. phpcbf is what formatters_by_ft
                -- actually uses — php-cs-fixer was never referenced anywhere.
                "phpcs", "prettier", "goimports", "gofumpt",
                "shfmt", "stylua", "shellcheck", "eslint_d",
            },
        },
    },
}
