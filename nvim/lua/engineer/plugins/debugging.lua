return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup DAP UI
      dapui.setup()

      -- Customize breakpoint signs and colors
      vim.fn.sign_define("DapBreakpoint", {
        text = "●",
        texthl = "DapBreakpoint",
        linehl = "DapBreakpointLine",
        numhl = "DapBreakpointNum",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "◐",
        texthl = "DapBreakpointCondition",
        linehl = "DapBreakpointLine",
        numhl = "DapBreakpointNum",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "○",
        texthl = "DapBreakpointRejected",
        linehl = "DapBreakpointLine",
        numhl = "DapBreakpointNum",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "◆",
        texthl = "DapLogPoint",
        linehl = "DapBreakpointLine",
        numhl = "DapBreakpointNum",
      })

      -- Set colors for breakpoints
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ff0000", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#ffaa00", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#666666", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#00ff00", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DapBreakpointLine", { bg = "#1a1a2e" })

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- PHP Configuration (XDebug)
      -- For Docker: XDebug connects back from container to host on port 9003
      -- Make sure docker-compose.yml exposes: ports: - 9003:9003
      dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { vim.fn.expand("~/.local/share/vscode-php-debug/out/phpDebug.js") },
      }

      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for XDebug",
          port = 9003,
          pathMappings = {
            ["/opt/pr/policyr"] = vim.fn.getcwd(),
          },
        },
      }

      -- JavaScript/TypeScript Configuration (requires node --inspect)
      dap.adapters.node = {
        type = "server",
        host = "127.0.0.1",
        port = 9229,
      }

      local js_config = {
        {
          type = "node",
          request = "attach",
          name = "Attach to Node.js (port 9229)",
          port = 9229,
          protocol = "inspector",
        },
      }

      dap.configurations.javascript = js_config
      -- TypeScript uses the same configuration as JavaScript
      dap.configurations.typescript = js_config
      dap.configurations.typescriptreact = js_config
      dap.configurations.javascriptreact = js_config

      -- Debug keybindings (Mac-friendly)
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<Leader>dc", dap.continue, opts)
      vim.keymap.set("n", "<Leader>dn", dap.step_over, opts)
      vim.keymap.set("n", "<Leader>di", dap.step_into, opts)
      vim.keymap.set("n", "<Leader>do", dap.step_out, opts)
      vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, opts)
      vim.keymap.set("n", "<Leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, opts)
      vim.keymap.set("n", "<Leader>dr", dap.repl.open, opts)
      vim.keymap.set("n", "<Leader>dl", dap.run_last, opts)
      vim.keymap.set("n", "<Leader>du", dapui.toggle, opts)
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  },
}
