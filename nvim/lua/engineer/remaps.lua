vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file explorer (netrw)" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line, keep cursor position" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half-page down, keep cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half-page up, keep cursor centered" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over selection without overwriting register" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Cmd+A: select whole file and copy it to the system clipboard (requires
-- `keybind = cmd+a=unbind` in ghostty/config so Ghostty forwards it here
-- instead of doing its own terminal-wide text selection).
vim.keymap.set("n", "<D-a>", "ggVG\"+y", { desc = "Select whole file and copy to system clipboard" })

-- Quick format trigger (wired to conform.nvim in formatting.lua)
vim.keymap.set({ "n", "v" }, "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer/selection" })

-- NOTE: <C-h/j/k/l> are intentionally left unbound here.
-- vim-tmux-navigator (installed via tmux, see plugins/utilities.lua note)
-- claims those keys to unify tmux <-> Neovim pane movement. Harpoon's file
-- nav was remapped to <leader>1-4 in utilities.lua to avoid colliding.

-- Debug keybindings (configured in plugins/debugging.lua):
-- <leader>dc: continue/start debug session
-- <leader>dn: step over (next)
-- <leader>di: step into
-- <leader>do: step out
-- <leader>db: toggle breakpoint
-- <leader>dB: set conditional breakpoint
-- <leader>dr: open REPL
-- <leader>dl: run last debug config
-- <leader>du: toggle debug UI
