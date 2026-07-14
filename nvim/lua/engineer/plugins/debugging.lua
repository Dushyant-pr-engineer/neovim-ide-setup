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
            -- Maps docker container path to host cwd. 
            -- Update "/opt/pr/policyr" if your docker container uses a different path.
            ["/opt/pr/policyr"] = vim.fn.getcwd(),
          },
        },
      }


      -- Debug keybindings (Mac-friendly)
      local base_opts = { noremap = true, silent = true }
      local function opts(desc)
        return vim.tbl_extend("force", base_opts, { desc = desc })
      end
      vim.keymap.set("n", "<Leader>dc", dap.continue, opts("Continue/start debug session"))
      vim.keymap.set("n", "<Leader>dn", dap.step_over, opts("Step over"))
      vim.keymap.set("n", "<Leader>di", dap.step_into, opts("Step into"))
      vim.keymap.set("n", "<Leader>do", dap.step_out, opts("Step out"))
      vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, opts("Toggle breakpoint"))
      vim.keymap.set("n", "<Leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, opts("Set conditional breakpoint"))
      vim.keymap.set("n", "<Leader>dr", dap.repl.open, opts("Open debug REPL"))
      vim.keymap.set("n", "<Leader>dl", dap.run_last, opts("Run last debug config"))
      vim.keymap.set("n", "<Leader>du", dapui.toggle, opts("Toggle debug UI"))
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  },
}
