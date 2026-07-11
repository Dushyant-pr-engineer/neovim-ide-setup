vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Cmd+A: select whole file and copy it to the system clipboard (requires
-- `keybind = cmd+a=unbind` in ghostty/config so Ghostty forwards it here
-- instead of doing its own terminal-wide text selection).
vim.keymap.set("n", "<D-a>", "ggVG\"+y")

-- Quick format trigger (wired to conform.nvim in formatting.lua)
vim.keymap.set({ "n", "v" }, "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = true })
end)

-- NOTE: <C-h/j/k/l> are intentionally left unbound here.
-- vim-tmux-navigator (installed via tmux, see plugins/utilities.lua note)
-- claims those keys to unify tmux <-> Neovim pane movement. Harpoon's file
-- nav was remapped to <leader>1-4 in utilities.lua to avoid colliding.
