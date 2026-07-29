return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({})
            telescope.load_extension("fzf")

            local builtin = require("telescope.builtin")
            -- Fast default: respects .gitignore, skips node_modules/build output/etc.
            vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>pF", function()
                -- Slower, exhaustive search: shows dotfiles and gitignored files,
                -- but still excludes .git since that's noise, not a file to open.
                builtin.find_files({ hidden = true, no_ignore = true, file_ignore_patterns = { "%.git/" } })
            end, { desc = "Find files (include hidden/gitignored)" })
            vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Find git-tracked files" })
            vim.keymap.set("n", "<leader>ps", function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end, { desc = "Grep string across the project" })
            vim.keymap.set("n", "<leader>gf", builtin.git_status, { desc = "Changed files (git status)" })

            -- Grep scoped to one folder: prompts for a directory, then a search
            -- string, and only greps inside that directory (unlike <leader>ps,
            -- which always searches the whole project).
            vim.keymap.set("n", "<leader>pg", function()
                local dir = vim.fn.input("Grep in folder > ", "", "dir")
                if dir == "" then
                    return
                end
                builtin.live_grep({ search_dirs = { dir } })
            end, { desc = "Grep string within a folder" })
        end,
    },
}
