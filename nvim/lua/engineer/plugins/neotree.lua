return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require("neo-tree").setup({
            close_if_last_window = false,
            enable_git_status = true,
            enable_diagnostics = true,
            default_component_configs = {
                indent = {
                    padding = 0,
                    with_markers = true,
                },
                icon = {
                    folder_closed = " ",
                    folder_open = " ",
                    folder_empty = "󰜌 ",
                    default = " ",
                },
                modified = {
                    symbol = "[+]",
                    highlight = "NeoTreeModified",
                },
                git_status = {
                    symbols = {
                        added = "✚",
                        deleted = "✖",
                        modified = "",
                        renamed = "󰁕",
                        untracked = "?",
                        ignored = "◌",
                        unstaged = "󰄱",
                        staged = "",
                        conflict = "",
                    },
                },
            },
            filesystem = {
                filtered_items = {
                    visible = false,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
                follow_current_file = {
                    enabled = true,
                    leave_dirs_open = false,
                },
                use_libuv_file_watcher = true,
            },
            window = {
                mappings = {
                    ["."] = "toggle_node",
                    ["<2-LeftMouse>"] = "open",
                    ["<cr>"] = "open",
                    ["l"] = "open",
                    ["h"] = "close_node",
                    ["C"] = "close_all_subnodes",
                    ["z"] = "close_all_nodes",
                    ["a"] = { "add", config = { show_path = "relative" } },
                    ["A"] = "add_directory",
                    ["d"] = "delete",
                    ["r"] = "rename",
                    ["y"] = "copy_to_clipboard",
                    ["x"] = "cut_to_clipboard",
                    ["p"] = "paste_from_clipboard",
                    ["c"] = "copy",
                    ["m"] = "move",
                    ["q"] = "close_window",
                    ["R"] = "refresh",
                    ["?"] = "show_help",
                    ["<"] = "prev_source",
                    [">"] = "next_source",
                    ["i"] = "show_file_details",
                },
            },
        })

        vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { silent = true, desc = "Toggle file explorer (Neo-tree)" })
        vim.keymap.set("n", "<leader>o", "<cmd>Neotree show<cr>", { silent = true, desc = "Show file explorer (Neo-tree)" })
    end,
}
