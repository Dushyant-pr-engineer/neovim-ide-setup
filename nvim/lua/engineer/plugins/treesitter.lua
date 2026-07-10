return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "php", "javascript", "typescript", "tsx", "go", "python",
                    "markdown", "markdown_inline", "bash", "yaml", "json",
                    "terraform", "hcl", "lua", "vim", "vimdoc", "query", "gitcommit", "diff",
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
}
