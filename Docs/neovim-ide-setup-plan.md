# Neovim IDE Setup — Design Rationale

**Context:** I'm a full-stack developer working across PHP (primary), JavaScript/TypeScript, Go, Python, and infrastructure-as-code (Terraform/Shell/YAML). I use Claude Code for pair programming and manage projects via Git. I work on Apple Silicon.

## Key Design Decisions & Why They Matter to Me

### 1. Why Ghostty (not Alacritty)

**My situation:** I use Claude Code inside tmux frequently, and I need Shift+Enter for newlines (not submitting).

**Why Ghostty:**
- Works natively on macOS (faster rendering, no performance gap vs Alacritty)
- Ships with Shift+Enter support built-in (Alacritty requires manual setup)
- Supports ligatures (useful when reading code with operator symbols)
- Still pairs perfectly with tmux—it doesn't try to replace it

**Trade-off I'm making:** Losing cross-platform portability (Alacritty runs everywhere; Ghostty is macOS-only). But I'm working on Apple Silicon, so this isn't a real constraint.

---

### 2. Why Tmux + Zsh (not bash, not iTerm2's native splits)

**My situation:** I have three panes open (Neovim, shell, Claude Code) and switch between them constantly. I restart my machine and need my session back.

**Why this combo:**
- **Tmux session persistence** — If I reboot, my layout (nvim + shell + Claude pane) is recreated exactly, with my tmux history intact
- **Unified keyboard navigation** — `Ctrl-h/j/k/l` moves me between Neovim splits AND tmux panes seamlessly (vim-tmux-navigator)
- **Zsh** gives me plugin support and a modern shell without needing to adopt a heavy framework

**What I gain:** My muscle memory works the same everywhere. No context-switching between "Neovim keys" and "tmux keys." My session survives reboots.

---

### 3. Why Lazy.nvim (not vim-plug, not Packer)

**My situation:** I work across 5+ languages with different LSP servers, formatters, and linters. Config needs to be maintainable and not clash with Claude Code's edits.

**Why Lazy:**
- **Modern spec loader** — Plugins load only when needed (faster startup, cleaner memory)
- **Lua-first** — Single, unified config language (no VimScript interop complexity)
- **Clear plugin organization** — Each plugin (LSP, formatting, debugging, etc.) is in its own file, so Claude Code edits don't cascade

**What I avoid:** VimScript boilerplate. Tangled plugin interdependencies. Slow startup times on large configs.

---

### 4. Why Language-Specific Formatters + Linters (not just LSP)

**My situation:** I work in PHP, JavaScript, Go, Python, Terraform. Each has different style expectations and my teams use different tools.

**Why separate:**
- **LSP is for semantic analysis** (hover docs, go-to-def, completion) — it's not designed to format or lint consistently
- **Formatters** (`prettier` for JS, `black` for Python, `phpcs-fixer` for PHP, etc.) are the canonical style checkers for each language
- **Linters** (eslint, ruff, golangci-lint, etc.) catch logic errors, not just style

**What I gain:** When I open a file, format-on-save works correctly for that language. No surprises when I commit.

---

### 5. Why Separate Debug Adapter Setup (not just LSP)

**My situation:** I debug PHP backend (XDebug) and JavaScript frontend (Chrome DevTools), often in the same session.

**Why DAP (Debug Adapter Protocol):**
- **Language-agnostic** — Neovim connects to any debugger (XDebug, Node, Go, etc.) via a standard interface
- **Breakpoint persistence** — My breakpoints stay set between runs
- **REPL access** — In a debugging session, I can eval expressions without stopping the debugger

**What I avoid:** Context-switching between "debugging in Neovim" and "debugging in browser DevTools" for different languages.

---

### 6. Why Machine-Specific Config Separate from Repo Config

**My situation:** I might clone this repo on a new machine (different OS, different user, different project path).

**Design:**
- **Repo contains** (`zshrc`, `nvim/init.lua`, `tmux.conf`, etc.) — shared, versioned, works everywhere
- **Machine config** (`~/.zshrc.local`, `~/.env`) — stays in home directory, never committed, overrides repo defaults
- **Shared secrets** (`.env` in repo) — API keys and credentials, symlinked to `~/.env`, sourced early so all shell files can use them

**What I gain:** I can clone this repo to a new machine and run `install.sh` once. The setup adapts to each machine without needing to edit repo files.

---

### 7. Why Claude Code Integration Needed Special Handling

**My situation:** I run `claude` in a tmux pane, and I expect Shift+Enter to add a newline (not submit).

**The problem:** Inside tmux, Claude Code can't detect Shift+Enter keystrokes or send desktop notifications — tmux traps the terminal events. Most guides ignore this.

**The solution:** Three environment variable tweaks that tell Claude Code to work inside tmux. These are in `ghostty/config` and `tmux.conf`.

**What I gain:** I can pair program with Claude Code without needing a separate terminal window.

---

## What Changed From the Original Plan

| Original Issue | Why It Mattered | What We Fixed |
|---|---|---|
| Missing PHP + Composer install | PHP is my primary language, but plan never installed it | Added both to ensure `intelephense` LSP can find a working PHP environment |
| No formatters/linters | For 5 languages, format-on-save and inline linting are as critical as LSP hover | Added `conform.nvim` + `nvim-lint` mapped per filetype |
| Outdated Neovim LSP setup | Old `mason-lspconfig` pattern is deprecated; would break in Neovim 0.11+ | Switched to native `vim.lsp.config()` + `vim.lsp.enable()` |
| Legacy completion engine | `nvim-cmp` still works but is no longer maintained; community moved to faster `blink.cmp` | Swapped engines for sub-millisecond completions |
| No tmux persistence | If tmux server died (reboot, crash), my session was lost | Added `tmux-resurrect` + `tmux-continuum` to rebuild on boot |
| Tmux ↔ Neovim key collision | Navigation keys were split (h/j/k/l in tmux only, different keys in Neovim) | Added `vim-tmux-navigator` for seamless unified navigation |
| Claude Code + tmux not addressed | Integration docs said "just run claude in tmux" but ignored Shift+Enter and notification issues | Configured terminal + tmux to properly forward both |

---

## Summary

This setup treats my development environment as a **unified system**, not a collection of disconnected tools:

- **Terminal + Tmux:** Persistent, resumable workspace with muscle-memory-consistent navigation
- **Neovim + LSP:** Semantic understanding of my code across 5+ languages
- **Formatters + Linters:** Language-native style enforcement, not guesswork
- **Claude Code integration:** Pair programming inside my editor, not in a separate window
- **Git awareness:** Tmux aliases and keybindings keep version control in my workflow

When I need to move to a new machine or onboard a teammate, the repo is portable (`install.sh` handles 90%), and the only setup work is filling in machine-specific config in `~/.zshrc.local`.
