# Vim & Tmux Cheat Sheet

Tailored to the config in `neovim-ide-setup/` — leader is `<Space>`, tmux prefix is `Ctrl-a`.

## Tmux

### Sessions

| Shortcut | Action |
|---|---|
| `tmux new -s NAME` | New named session |
| `tmux attach -t NAME` | Attach to a session |
| `tmux ls` | List sessions |
| `prefix d` | Detach from session |
| `prefix s` | Switch session (interactive list) |
| `prefix $` | Rename session |

### Windows

| Shortcut | Action |
|---|---|
| `prefix c` | New window |
| `prefix ,` | Rename window |
| `prefix n` / `prefix p` | Next / previous window |
| `prefix 0-9` | Jump to window number |
| `prefix w` | Window list (interactive) |
| `prefix &` | Kill window |

### Panes

| Shortcut | Action |
|---|---|
| `prefix \|` | Split horizontally (custom — keeps current path) |
| `prefix -` | Split vertically (custom — keeps current path) |
| `Ctrl-h/j/k/l` | Move between panes — **and** into/out of Neovim splits (vim-tmux-navigator) |
| `prefix z` | Zoom/unzoom current pane |
| `prefix x` | Kill current pane |
| `prefix {` / `prefix }` | Swap pane left / right |
| `prefix Ctrl-arrow` | Resize pane |
| `prefix q` | Show pane numbers |

### Copy mode (vi-style, since `mode-keys vi` is set)

| Shortcut | Action |
|---|---|
| `prefix [` | Enter copy mode |
| `v` | Start selection (in copy mode) |
| `y` | Yank selection and exit copy mode |
| `prefix ]` | Paste |
| `q` | Exit copy mode |
| Mouse drag | Select and auto-copy (`mouse on` + tmux-yank) |

### Plugins (installed via `prefix I`)

| Shortcut | Action |
|---|---|
| `prefix I` | Install plugins listed in `tmux.conf` |
| `prefix U` | Update plugins |
| `prefix Ctrl-s` | Manually save session (tmux-resurrect) |
| `prefix Ctrl-r` | Manually restore session (tmux-resurrect) |
| — | tmux-continuum auto-saves every 15 min and auto-restores on tmux start |

### Claude Code inside tmux

- `Shift+Enter` inserts a newline instead of submitting (needs `allow-passthrough on` + `extended-keys` — already set).
- Desktop notifications reach the outer terminal correctly with the same settings.
- Run Claude Code in its own window (`prefix c`), keep Neovim in another, flip with `prefix 1` / `prefix 2`.

---

## Neovim

Leader key is `<Space>`.

### Modes

| Key | Mode |
|---|---|
| `i` / `a` | Insert (before / after cursor) |
| `v` / `V` / `Ctrl-v` | Visual / Visual line / Visual block |
| `Esc` or `Ctrl-c` | Back to Normal |
| `:` | Command-line mode |
| `R` | Replace mode |

### Movement

| Key | Action |
|---|---|
| `h j k l` | Left / down / up / right |
| `w` / `b` / `e` | Next word / back word / end of word |
| `0` / `^` / `$` | Start of line / first non-blank / end of line |
| `gg` / `G` | Top / bottom of file |
| `{n}G` or `:n` | Go to line n |
| `Ctrl-d` / `Ctrl-u` | Half-page down / up (custom: recentres with `zz`) |
| `%` | Jump to matching bracket |
| `*` / `#` | Search word under cursor forward / backward |
| `f{char}` / `t{char}` | Jump to / till next char on line |
| `` `mark `` / `'mark` | Jump to exact / line position of a mark |

### Editing

| Key | Action |
|---|---|
| `x` | Delete char |
| `dd` / `yy` | Delete / yank line |
| `dw` / `de` / `d$` | Delete to next word / end of word / end of line |
| `cw`, `ciw`, `ci"`, `ci(` | Change word / inner word / inside quotes / inside parens |
| `p` / `P` | Paste after / before cursor |
| `u` / `Ctrl-r` | Undo / redo |
| `.` | Repeat last change |
| `>>` / `<<` | Indent / outdent line |
| `J` (normal) | Join line below, cursor stays put (custom remap) |
| `J` / `K` (visual) | Move selected lines down / up, reselect (custom remap) |
| `<leader>p` (visual/x) | Paste over selection without overwriting register (custom) |
| `<leader>y` | Yank to system clipboard (custom) |
| `<leader>Y` | Yank line to system clipboard (custom) |
| `<leader>f` | Format buffer via conform.nvim (custom) |

### Search & replace

| Key | Action |
|---|---|
| `/pattern` / `?pattern` | Search forward / backward |
| `n` / `N` | Next / previous match |
| `:%s/old/new/g` | Replace all in file |
| `:%s/old/new/gc` | Replace all, confirm each |
| — | Search is case-insensitive by default; typing any uppercase letter in the pattern makes it case-sensitive again (`ignorecase`+`smartcase`) |
| `/pattern\c` / `/pattern\C` | Force a single search to be case-insensitive / case-sensitive, overriding the above |

### Folding (treesitter-based)

Folds start fully open (`foldlevel`/`foldlevelstart = 99`) — these are for when you fold something manually and want it back.

| Key | Action |
|---|---|
| `za` | Toggle fold under cursor |
| `zo` / `zc` | Open / close fold under cursor |
| `zO` / `zC` | Open / close fold under cursor, recursively (nested folds too) |
| `zR` | Open all folds in buffer |
| `zM` | Close all folds in buffer |
| `zj` / `zk` | Jump to next / previous fold |

### Windows, buffers, files

| Key | Action |
|---|---|
| `<leader>pv` | Open file explorer (`:Ex`, custom) |
| `<leader>pf` | Telescope: find files (custom) |
| `Ctrl-p` | Telescope: git files (custom) |
| `<leader>ps` | Telescope: grep string, prompts for input (custom) |
| `:bn` / `:bp` | Next / previous buffer |
| `:bd` | Close buffer |
| `Ctrl-w s` / `Ctrl-w v` | Split window horizontally / vertically |

### LSP (on attach — `gopls`, `pyright`, `intelephense`, `ts_ls`, `ruff`, `terraformls`, etc.)

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `K` | Hover docs |
| `<leader>vws` | Workspace symbol search |
| `<leader>vd` | Show diagnostic in floating window |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>vca` | Code action |
| `<leader>vrr` | References |
| `<leader>vrn` | Rename symbol |

### Completion (blink.cmp)

| Key | Action |
|---|---|
| `Ctrl-space` | Open completion menu |
| `Ctrl-y` | Accept completion |
| `Tab` / `Shift-Tab` or arrows | Navigate suggestions |

### Git (fugitive + gitsigns + lazygit)

| Key | Action |
|---|---|
| `<leader>gs` | Open `:Git` status (fugitive) |
| `<leader>gg` | Open LazyGit in a floating window — branch tree, staging, rebase, stash, all interactive |
| `<leader>gb` | Toggle inline current-line git blame (gitsigns) |
| gitsigns gutter | Shows added/changed/removed lines automatically |

Statusline (lualine) shows the current branch name at the bottom at all times — no key needed.

### Harpoon (quick file switching)

| Key | Action |
|---|---|
| `<leader>a` | Add current file to Harpoon |
| `Ctrl-e` | Toggle Harpoon quick menu |
| `<leader>1` / `2` / `3` / `4` | Jump to Harpoon file 1-4 (remapped off `Ctrl-h/j/k/l` to avoid clashing with tmux-navigator) |

### Undo history

| Key | Action |
|---|---|
| `<leader>u` | Toggle Undotree |

### Which-key

Press `<Space>` (or any prefix) and pause — a popup lists every available leader mapping, so this cheat sheet is really just a backup for the built-in one.

---

## Tmux ↔ Neovim (unified navigation)

`Ctrl-h/j/k/l` moves between panes whether the focused pane is tmux or a Neovim split — no separate keybinding sets to remember, no need to check which one you're in first.
