# Working on a Project: Nvim + Tmux Workflow

A walkthrough of *how* to use this setup day-to-day, not just what each key
does. For the full key reference, see `vim-tmux-cheatsheet.md` — this doc is
about stitching those keys into an actual workflow.

## 1. Starting up

Opening a terminal auto-attaches (or creates) the `dev` tmux session
(`zsh/tmux-autostart.zsh`) — you're dropped straight into tmux, no manual
`tmux attach` needed.

For a specific project, don't just work inside the `dev` session's first
window — give the project its own **named window** (or session, if you
regularly juggle several repos at once):

```
prefix ,          rename the current window to the project name
prefix c          new window (e.g. one per project, or one for editor / one for claude)
prefix 0-9        jump straight to a window by number
```

Session persistence is automatic: `tmux-continuum` saves every 15 min and
restores on tmux start, and `tmux-resurrect` (`prefix Ctrl-s` / `Ctrl-r`) can
snapshot/restore on demand — including reopening Neovim with its buffers via
`@resurrect-strategy-nvim 'session'`. Closing your laptop mid-task is safe.

## 2. Laying out panes for a project

A layout that works well with this config's LSP + Claude Code setup:

```
prefix |          split editor pane vertically (opens in the same cwd)
prefix -          split horizontally
```

Typical 3-pane layout for a work session:
- **Left/main pane** — `nvim`, the actual editing.
- **Right-top pane** — `claude` (Claude Code), for delegating side-tasks
  while you keep editing.
- **Right-bottom pane** — a plain shell for running tests/build commands.

`Ctrl-h/j/k/l` moves between all three panes *and* into/out of Neovim splits
seamlessly (vim-tmux-navigator) — you never need to think about whether the
pane you're moving into is tmux or Neovim.

Because `vim.o.autoread` + a `FocusGained`/`BufEnter` → `checktime` autocmd
is set up, if Claude Code edits a file in the adjacent pane, switching focus
back to the Neovim pane picks up the change automatically — no `:e!` needed.

## 3. Getting into the project (navigation)

Don't `cd` and re-launch `nvim <file>` per file — open Neovim once at the
project root and navigate from inside it:

| Goal | Key | Notes |
|---|---|---|
| Jump to a known file by name | `<leader>pf` | Telescope find_files — fastest for "I know roughly what it's called" |
| Jump to a git-tracked file | `Ctrl-p` | Telescope git_files — only works inside a git repo |
| Search file *contents* across the project | `<leader>ps` | Prompts for a grep string |
| Browse the directory tree | `<leader>pv` | Opens netrw (`:Ex`) in the current window |
| Pin your 3-4 active files and hop between them | `<leader>a` to add, `<leader>1`-`4` to jump | Harpoon — faster than re-fuzzy-finding the same file repeatedly during a task |

**Suggested habit**: when you start a task that touches a handful of files,
`<leader>a` each one as you first open it. For the rest of the task, hop
between them with `<leader>1-4` instead of going back through Telescope —
it's a flat jump, not a fuzzy search.

## 4. The edit loop

Once you're in a file, the LSP (`gopls`, `intelephense`, `ts_ls`, `pyright`,
`ruff`, `terraformls`, etc. — auto-attached per filetype) drives most of the
navigation and refactoring:

| Goal | Key |
|---|---|
| Jump to a symbol's definition | `gd` |
| Peek docs/types without leaving the file | `K` |
| Find every usage of a symbol | `<leader>vrr` |
| Rename a symbol project-wide | `<leader>vrn` |
| Find a symbol anywhere in the project by name | `<leader>vws` |
| Get a quickfix / code action (implement interface, add import, etc.) | `<leader>vca` |
| See what's wrong on this line | `<leader>vd` |
| Hop between errors/warnings in the buffer | `[d` / `]d` |

Completion (`blink.cmp`) suggests as you type from the LSP, buffer words,
snippets, and paths — `Ctrl-space` to force it open, `Ctrl-y` to accept,
`Tab`/arrows to navigate.

**Formatting is automatic on save** (conform.nvim, `format_on_save`) — you
don't need to think about it for PHP/JS/TS/Go/Python/Terraform/Shell/
YAML/JSON/Markdown/Lua. `<leader>f` triggers it manually if you ever need to
format without saving.

Folds start fully open (`foldlevel = 99`), so large files display in full
immediately — see `vim-tmux-cheatsheet.md`'s Folding section (`za`/`zR`/`zM`)
if you want to collapse class/function bodies while skimming.

## 5. Reviewing your own change before committing

- Gutter signs (gitsigns) show added/changed/removed lines live as you type
  — no need to run `git diff` to see what you've touched so far.
- `<leader>gs` opens `:Git` status (fugitive) for staging, or a full diff
  view, without leaving Neovim.
- `<leader>u` toggles Undotree if you need to step back through edit history
  on a file rather than relying on git.

## 6. A full example flow

Picking up a task that involves reading a controller, tracing a function
call, fixing a bug, and renaming a poorly-named variable:

1. `prefix ,` — rename the tmux window to the task/ticket name.
2. `nvim` in the project root (or it's already open from a resurrect
   restore).
3. `<leader>pf` → type the controller filename → `<Enter>`.
4. `<leader>a` to pin it to Harpoon slot 1.
5. `gd` on the function call to jump to its definition (may leave the
   original file — that's fine, Harpoon slot 1 still points home).
6. `<leader>vrr` to see every call site before changing the signature.
7. Make the fix; `<leader>vrn` to rename the bad variable everywhere in one
   shot.
8. `<leader>1` to jump back to the pinned controller and sanity-check the
   call site.
9. Save — formatting happens automatically.
10. Glance at the gitsigns gutter, then `<leader>gs` to review and stage.
11. Flip to the Claude Code pane (`Ctrl-l` or `prefix` + window number) to
    ask for a second look or to draft the commit message, then back
    (`Ctrl-h`) to Neovim — no context switch cost, both are one keystroke
    away.

## See also

- `vim-tmux-cheatsheet.md` — full key reference (this doc assumes you'll
  look things up there as needed).
- `README.md` — install/setup instructions and the reasoning behind
  non-obvious config choices.
