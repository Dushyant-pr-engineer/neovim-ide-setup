# Debugging PolicyR

## Quick Reference

- **PHP Backend:** Use Neovim + XDebug via nvim-dap (keybindings below)
- **Frontend (React/JS/TS):** Use Chrome DevTools in the browser (F12 → Sources)

## Prerequisites

- Docker container `policyr` running locally.
- `nvim-dap`, `nvim-dap-ui` installed (see `neovim-ide-setup/nvim/lua/engineer/plugins/debugging.lua`).
- The `xdebug/vscode-php-debug` adapter installed at `~/.local/share/vscode-php-debug`
  (bootstrapped by `neovim-ide-setup/install.sh`, Step 5b — clones and runs `npm install && npm run build`).

## PHP (XDebug)

### How it works

XDebug runs inside the `policyr` container. On a triggered request, it opens
an **outbound** connection to `host.docker.internal:9003` on your Mac. Nothing
needs to listen on the container side and no inbound Docker port mapping is
required for this — only the reverse (container → host) matters.

On the host, `vscode-php-debug` (spawned by `nvim-dap`) listens on port 9003,
speaks XDebug's DBGp protocol, and translates it to DAP for `nvim-dap`.

### Config

- Container XDebug ini: `ops/docker/templates/apache2.php.ini` (`[xdebug]` block),
  mounted into the container at `/etc/php/8.5/apache2/php.ini`.
- `xdebug.mode=debug,coverage` is set, but `xdebug.start_with_request` is left
  unset, so it takes its implicit `default` value. For `mode=debug`, `default`
  resolves to `trigger` behavior — a debug session only starts when the
  request carries an `XDEBUG_TRIGGER` cookie/GET/POST param. Without a
  trigger, XDebug never attempts to connect, and breakpoints silently never
  hit. (`default`'s meaning is mode-dependent: it resolves to `yes` under
  `mode=profile` and `no` under `mode=gcstats` — see the
  [Xdebug docs](https://xdebug.org/docs/remote#start_with_request) if you
  ever change `xdebug.mode`.)
- `xdebug.client_host=host.docker.internal`, `xdebug.client_port=9003` — where
  XDebug connects out to.
- Nvim side: `nvim/lua/engineer/plugins/debugging.lua` defines `dap.adapters.php`
  (spawns the `vscode-php-debug` adapter) and `dap.configurations.php` (request
  type `launch`, port `9003`, `pathMappings` mapping the container's
  `/opt/pr/policyr` to your local checkout).

### Enabling a debug session per-request

Since the trigger is cookie/param-based, turn it on only when you need it:

- **Browser DevTools console** (no extension needed):
  ```js
  document.cookie = "XDEBUG_TRIGGER=1; path=/"
  ```
  Every request from that browser tab now triggers a debug session until you
  clear the cookie.
- **Xdebug Helper browser extension** (Chrome/Firefox) — toggles the same
  cookie with one click.
- **One-off request** — append `?XDEBUG_TRIGGER=1` to a specific URL.

### Debugging workflow

1. Open a `.php` file in the `policyr` repo in Neovim. Confirm `:set filetype?`
   reports `php`.
2. Set a breakpoint: `<Leader>db`.
3. Start listening: `<Leader>dc` (picks the "Listen for XDebug" configuration).
4. Enable the trigger (see above) and make the request that hits your
   breakpoint.
5. Step through with `<Leader>dn` (step over), `<Leader>di` (step into),
   `<Leader>do` (step out); inspect the REPL with `<Leader>dr`; toggle the
   debug UI with `<Leader>du`; re-run the last session with `<Leader>dl`.

### Troubleshooting

- **"Couldn't connect to 0.0.0.0:9003"** — `dap.adapters.php` was set to
  `type = "server"`, which means "connect to an already-running DAP server."
  It must be `type = "executable"` spawning the `vscode-php-debug` adapter,
  which itself opens the listening port.
- **"Attach requests are not supported"** — `xdebug/vscode-php-debug` only
  implements the `launch` request type, not `attach`. Set
  `dap.configurations.php[*].request = "launch"`.
- **Connects but breakpoint never hits** — check `xdebug.start_with_request`
  (unset = `default`, which behaves as `trigger` under `mode=debug`). It
  needs the `XDEBUG_TRIGGER` cookie/param on the request; without it, XDebug
  never even attempts the connection.
- **Breakpoint rejected / wrong file** — check `pathMappings`: the container
  path must exactly match how XDebug reports the file (verify via
  `docker exec policyr sh -c "cat /path/to/php.ini"` or the app's
  `document_root` in `config.ini.php`, currently `/opt/pr/policyr`).
- Config changes to `apache2.php.ini` only take effect after reloading Apache
  in the container: `docker exec policyr sh -c "apache2ctl graceful"`. Also
  check for stray overrides in `/etc/php/8.5/apache2/conf.d/*.ini` — those
  load after `php.ini` and silently win.

## JavaScript / TypeScript (portal/)

### Debugging with Browser DevTools (Recommended)

For React/frontend debugging, use **Chrome/Firefox DevTools** instead of nvim-dap.
This is the standard, most reliable approach for debugging web applications.

**Workflow:**

1. Start the dev server:
   ```sh
   cd portal && npm start
   ```
   The webpack dev server starts on `http://localhost:8080` with sourcemaps enabled.

2. Open Chrome DevTools: **F12** (or Cmd+Option+I on Mac)

3. Go to the **Sources** tab and find your file under `webpack://src/pages/YourPage/index.tsx`

4. Click line numbers to set breakpoints directly in the editor

5. Navigate the app in the browser — breakpoints pause execution

6. Use the DevTools UI to:
   - Step over (`F10`), step into (`F11`), step out (Shift+F11)
   - Inspect variables and the call stack
   - Evaluate expressions in the console

**Note:** Webpack is configured with `devtool: 'source-map'` in development mode,
which generates proper sourcemaps for accurate file/line mapping in DevTools.

## Nvim DAP Keybindings (PHP only, leader = `<Space>`)

These keybindings work when debugging PHP with XDebug.

| Key | Action |
|---|---|
| `<Leader>db` | Toggle breakpoint |
| `<Leader>dB` | Set conditional breakpoint (prompts for condition) |
| `<Leader>dc` | Continue / listen for XDebug connection |
| `<Leader>dn` | Step over |
| `<Leader>di` | Step into |
| `<Leader>do` | Step out |
| `<Leader>dr` | Open REPL |
| `<Leader>dl` | Re-run last debug session |
| `<Leader>du` | Toggle debug UI |
