return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "tokyonight",
                globalstatus = true, -- one statusline across all splits, not one per window
            },
        },
    },
}
