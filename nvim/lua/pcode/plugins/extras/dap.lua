return {
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    event = "BufRead",
    dependencies = {
      {
        "mfussenegger/nvim-dap",
        lazy = true,
        config = function()
          -- Sign HARUS terdefinisi saat nvim-dap load (sebelum toggle_breakpoint
          -- dipanggil via F9), kalau tidak sign_place gagal → ikon tak muncul.
          -- Pakai Unicode standar (bukan Nerd Font glyph) supaya text pasti render.
          local signs = {
            DapBreakpoint = { text = "●", texthl = "DiagnosticSignError" },
            DapBreakpointCondition = { text = "◆", texthl = "DiagnosticSignWarn" },
            DapLogPoint = { text = "◆", texthl = "DiagnosticSignInfo" },
            DapStopped = { text = "▶", texthl = "DiagnosticSignWarn", linehl = "Visual" },
            DapBreakpointRejected = { text = "○", texthl = "DiagnosticSignHint" },
          }
          for name, opt in pairs(signs) do
            vim.fn.sign_define(name, opt)
          end
        end,
      },
      { "nvim-neotest/nvim-nio", lazy = true },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          virt_text_win_col = 80,
        },
      },
    },
    config = function()
      -- Define sign breakpoint DULU (Unicode standar biar text pasti render).
      local signs = {
        DapBreakpoint = { text = "●", texthl = "DiagnosticSignError" },
        DapBreakpointCondition = { text = "◆", texthl = "DiagnosticSignWarn" },
        DapLogPoint = { text = "◆", texthl = "DiagnosticSignInfo" },
        DapStopped = { text = "▶", texthl = "DiagnosticSignWarn", linehl = "Visual" },
        DapBreakpointRejected = { text = "○", texthl = "DiagnosticSignHint" },
      }
      for name, opt in pairs(signs) do
        vim.fn.sign_define(name, opt)
      end
      require("pcode.user.dapui")
    end,
    keys = {
      { "<leader>d", "", desc = "  Debug" },
      { "<F9>", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "Toggle Breakpoint (F9)" },
      { "<F5>", "<cmd>lua require'dap'.continue()<cr>", desc = "Start/Continue (F5)" },
      { "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "Toggle Breakpoint" },
      { "<leader>bc", "<cmd>lua require'dap'.continue()<cr>", desc = "Start/Continue Debug" },

      { "<leader>dt", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "Toggle Breakpoint" },
      { "<leader>db", "<cmd>lua require'dap'.step_back()<cr>", desc = "Step Back" },
      { "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", desc = "Continue" },
      { "<leader>dC", "<cmd>lua require'dap'.run_to_cursor()<cr>", desc = "Run To Cursor" },
      { "<leader>dd", "<cmd>lua require'dap'.disconnect()<cr>", desc = "Disconnect" },
      { "<leader>dg", "<cmd>lua require'dap'.session()<cr>", desc = "Get Session" },
      { "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", desc = "Step Into" },
      { "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", desc = "Step Over" },
      { "<leader>du", "<cmd>lua require'dap'.step_out()<cr>", desc = "Step Out" },
      { "<leader>dp", "<cmd>lua require'dap'.pause()<cr>", desc = "Pause" },
      { "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", desc = "Toggle Repl" },
      { "<leader>ds", "<cmd>lua require'dap'.continue()<cr>", desc = "Start" },
      { "<leader>dq", "<cmd>lua require'dap'.close()<cr>", desc = "Quit" },
      { "<leader>dU", "<cmd>lua require'dapui'.toggle({reset = true})<cr>", desc = "Toggle UI" },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    lazy = true,
    event = "BufRead",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {})
      opts.automatic_setup = true
      opts.handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require("mason-nvim-dap").default_setup(config)
        end,
      }
      return opts
    end,
    -- enabled = vim.fn.has("win32") == 0,
    config = function(_, opts)
      require("mason").setup()
      require("mason-nvim-dap").setup(opts)
    end,
  },
}
