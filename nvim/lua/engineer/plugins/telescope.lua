return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>pf", function()
                -- find_files skips dotfiles by default; hidden = true shows them,
                -- but still exclude .git since that's noise, not a file to open.
                builtin.find_files({ hidden = true, file_ignore_patterns = { "%.git/" } })
            end, {})
            vim.keymap.set("n", "<C-p>", builtin.git_files, {})
            vim.keymap.set("n", "<leader>ps", function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
            vim.keymap.set("n", "<leader>gf", builtin.git_status, { desc = "Changed files (git status)" })
        end,
    },
}
