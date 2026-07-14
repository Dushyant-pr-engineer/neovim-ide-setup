return {
    {
        "ThePrimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("harpoon").setup({})

            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")

            vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Add file to Harpoon" })
            vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, { desc = "Toggle Harpoon quick menu" })
            -- Remapped off <C-h/j/k/l> (originally Harpoon's file-nav keys) to
            -- <leader>1-4: those keys are claimed by vim-tmux-navigator below
            -- for seamless tmux <-> Neovim pane movement.
            vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end, { desc = "Jump to Harpoon file 1" })
            vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end, { desc = "Jump to Harpoon file 2" })
            vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end, { desc = "Jump to Harpoon file 3" })
            vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end, { desc = "Jump to Harpoon file 4" })

            vim.keymap.set("n", "<C-S-P>", ui.nav_prev, { desc = "Previous Harpoon file" })
            vim.keymap.set("n", "<C-S-N>", ui.nav_next, { desc = "Next Harpoon file" })
        end
    },
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })
        end
    },
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Open Git status (fugitive)" })
        end
    },
    {
        -- Interactive branch tree / staging / rebase TUI, in a floating window.
        "kdheepak/lazygit.nvim",
        cmd = { "LazyGit" },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
    },
    {
        -- inline git diff markers in the gutter + hunk navigation + line blame
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+", hl = "GitSignsAdd" },
                change = { text = "m", hl = "GitSignsChange" },
                delete = { text = "-", hl = "GitSignsDelete" },
                topdelete = { text = "-", hl = "GitSignsDelete" },
                changedelete = { text = "~", hl = "GitSignsChange" },
                untracked = { text = "?", hl = "GitSignsUntracked" },
            },
            signcolumn = true,
            numhl = false,
            linehl = false,
            word_diff = false,
            current_line_blame = true,
            current_line_blame_opts = { delay = 300 },
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")
                vim.keymap.set("n", "<leader>gb", gitsigns.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle current line blame" })
                vim.keymap.set("n", "]h", gitsigns.next_hunk, { buffer = bufnr, desc = "Next git hunk" })
                vim.keymap.set("n", "[h", gitsigns.prev_hunk, { buffer = bufnr, desc = "Prev git hunk" })
                vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { buffer = bufnr, desc = "Preview hunk diff" })
                vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
                vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
            end,
        },
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
    {
        "wakatime/vim-wakatime",
        lazy = false,
    },
}
