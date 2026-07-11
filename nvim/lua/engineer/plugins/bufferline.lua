return {
    {
        "akinsho/bufferline.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        version = "*",
        opts = {
            options = {
                mode = "buffers", -- one tab per open buffer, not per vim tabpage
                numbers = "ordinal", -- shows 1, 2, 3... matching the <leader>bN keymaps below
                diagnostics = "nvim_lsp",
                offsets = {
                    { filetype = "netrw", text = "File Explorer", separator = true },
                },
            },
        },
        config = function(_, opts)
            require("bufferline").setup(opts)
            -- <leader>b1..b9 jump straight to the buffer tab with that ordinal.
            -- Namespaced under <leader>b (matches <leader>bd) because Alt+1..5
            -- is claimed by tmux pane-nav and <leader>1..4 by Harpoon.
            for i = 1, 9 do
                vim.keymap.set("n", "<leader>b" .. i, function()
                    require("bufferline").go_to(i, true)
                end, { desc = "Go to buffer tab " .. i })
            end
            vim.keymap.set("n", "<A-,>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
            vim.keymap.set("n", "<A-.>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
            vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
        end,
    },
}
