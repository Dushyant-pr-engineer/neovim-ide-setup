return {
    {
        "folke/tokyonight.nvim",
        config = function()
            vim.cmd("colorscheme tokyonight-storm")
            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

            -- Gitsigns custom colors
            vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#9ece6a", bold = true })
            vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#e0af68", bold = true })
            vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f7768e", bold = true })
            vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = "#7aa2f7", bold = true })
        end,
    },
}
