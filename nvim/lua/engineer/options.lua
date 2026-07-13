vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true -- search is case-insensitive by default...
vim.opt.smartcase = true -- ...unless the pattern itself has an uppercase letter
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes" -- prevents text jump when diagnostics/gitsigns appear
vim.opt.updatetime = 300 -- faster CursorHold for diagnostic hover (ms)

-- Treesitter foldexpr (set up in plugins/treesitter.lua) assigns a fold
-- level per nesting depth. foldlevel=0 (Neovim's default) collapses
-- everything, including top-level class/function defs, down to a handful of
-- lines. foldlevel=1 keeps the top level open (class/function signatures
-- visible) while collapsing what's nested inside them (method bodies etc.)
-- — a skimmable outline view by default, not a wall of squashed text.
vim.opt.foldlevel = 1
vim.opt.foldlevelstart = 1

-- Pick up file changes made outside Neovim (e.g. by Claude Code in the
-- adjacent tmux window) without a manual reload.
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    command = "checktime",
})
