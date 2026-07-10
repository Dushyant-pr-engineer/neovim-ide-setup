return {
    {
        "ThePrimeagen/harpoon",
        config = function()
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")
            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)
            -- Remapped off <C-h/j/k/l> (originally Harpoon's file-nav keys) to
            -- <leader>1-4: those keys are claimed by vim-tmux-navigator below
            -- for seamless tmux <-> Neovim pane movement.
            vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end)
        end
    },
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        end
    },
    {
        -- new: inline git diff markers in the gutter + hunk navigation
        "lewis6991/gitsigns.nvim",
        opts = {},
    },
    {
        -- new: discoverability for all the <leader> mappings above
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        -- Neovim-side half of tmux <-> nvim pane navigation (tmux-side half
        -- is installed via TPM, see tmux/tmux.conf). Once loaded, it supplies
        -- its own <C-h/j/k/l> mappings automatically — no extra remap needed.
        "christoomey/vim-tmux-navigator",
        lazy = false,
    },
}
