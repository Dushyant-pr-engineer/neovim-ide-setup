return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "tokyonight",
                globalstatus = true, -- one statusline across all splits, not one per window
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {
                    {
                        "branch",
                        fmt = function(name)
                            return #name > 15 and (name:sub(1, 15) .. "...") or name
                        end,
                    },
                    "diff",
                    "diagnostics",
                },
                lualine_c = { { "filename", path = 1 } }, -- path = 1 shows path relative to cwd
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },
}
