return {
    {
        "akinsho/bufferline.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        version = "*",
        opts = {
            options = {
                mode = "buffers", -- one tab per open buffer, not per vim tabpage
                numbers = "ordinal", -- shows 1, 2, 3... matching the <A-n> keymaps below
                diagnostics = "nvim_lsp",
                offsets = {
                    { filetype = "netrw", text = "File Explorer", separator = true },
                },
            },
        },
        config = function(_, opts)
            require("bufferline").setup(opts)
            for i = 1, 9 do
                vim.keymap.set("n", "<A-" .. i .. ">", function()
                    require("bufferline").go_to(i, true)
                end, { desc = "Go to buffer " .. i })
            end
            vim.keymap.set("n", "<A-,>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
            vim.keymap.set("n", "<A-.>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
            vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
        end,
    },
}
