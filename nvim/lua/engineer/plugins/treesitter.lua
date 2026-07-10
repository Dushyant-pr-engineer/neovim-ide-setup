-- nvim-treesitter's `main` branch (the current default) dropped the old
-- `nvim-treesitter.configs` setup() API in favor of a minimal core: parsers
-- are installed via `install()` and highlighting/indent are enabled
-- per-filetype through Neovim's built-in `vim.treesitter.start()`.
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            local parsers = {
                "php", "javascript", "typescript", "tsx", "go", "python",
                "markdown", "markdown_inline", "bash", "yaml", "json",
                "terraform", "hcl", "lua", "vim", "vimdoc", "query", "gitcommit", "diff",
            }
            require("nvim-treesitter").install(parsers)

            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "php", "javascript", "javascriptreact", "typescript", "typescriptreact",
                    "go", "python", "markdown", "sh", "yaml", "json",
                    "terraform", "hcl", "lua", "vim", "help", "query", "gitcommit", "diff",
                },
                callback = function()
                    vim.treesitter.start()
                    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo[0][0].foldmethod = "expr"
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
}
