local config_file = "jest.config.ts"
local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "html", "javascript", "typescript", "tsx", "css", "json", "jsonc" })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "html", "eslint", "cssls", "emmet_ls", "jsonls", "ts_ls" })
      -- aktifkan emmet_ls untuk React Native (JSX/TSX) + file .ts/.js polos
      -- dibungkus vim.schedule agar dijalankan setelah auto-lsp setup (menang override)
      vim.schedule(function()
        vim.lsp.config("emmet_ls", {
          filetypes = {
            "astro",
            "css",
            "eruby",
            "html",
            "htmlangular",
            "htmldjango",
            "javascript",
            "javascriptreact",
            "less",
            "pug",
            "sass",
            "scss",
            "svelte",
            "templ",
            "typescript",
            "typescriptreact",
            "vue",
            "php",
          },
        })
        pcall(vim.lsp.enable, "emmet_ls")
      end)
    end,
  },
  {
    "pojokcodeid/auto-conform.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local package = "prettier"
      vim.list_extend(opts.ensure_installed, { package })
      opts.formatters_by_ft.javascript = { package }
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/nvim-nio",
      "marilari88/neotest-vitest",
    },
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "npm test -- ",
          jestConfigFile = function()
            local file = vim.fn.expand("%:p")
            if string.find(file, "/packages/") then
              return string.match(file, "(.-/[^/]+/)src") .. config_file
            end
            return vim.fn.getcwd() .. "/" .. config_file
          end,
          cwd = function()
            local file = vim.fn.expand("%:p")
            if string.find(file, "/packages/") then
              return string.match(file, "(.-/[^/]+/)src")
            end
            return vim.fn.getcwd()
          end,
        },
        ["neotest-vitest"] = {},
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
    },
    config = function(_, opts)
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            -- Replace newline and tab characters with space for more compact diagnostics
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      opts.consumers = opts.consumers or {}
      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters or {}) do
          if type(name) == "number" then
            if type(config) == "string" then
              config = require(config)
            end
            adapters[#adapters + 1] = config
          elseif config ~= false then
            local adapter = require(name)
            if type(config) == "table" and not vim.tbl_isempty(config) then
              local meta = getmetatable(adapter)
              if adapter.setup then
                adapter.setup(config)
              elseif meta and meta.__call then
                adapter(config)
              else
                error("Adapter " .. name .. " does not support setup")
              end
            end
            adapters[#adapters + 1] = adapter
          end
        end
        opts.adapters = adapters
      end

      require("neotest").setup(opts)
    end,
    -- stylua: ignore
    keys = {
      { "<leader>T","",desc="  Test"},
      { "<leader>Tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File" },
      { "<leader>Tr", function() require("neotest").run.run() end, desc = "Run Nearest" },
      { "<leader>TT", function() require("neotest").run.run(vim.loop.cwd()) end, desc = "Run All Test Files" },
      { "<leader>Tl", function() require("neotest").run.run_last() end, desc = "Run Last" },
      { "<Leader>Ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      { "<leader>To", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
      { "<Leader>TO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
      { "<Leader>TS", function() require("neotest").run.stop() end, desc = "Stop" },
    },
  },
  {
    "pojokcodeid/npm-runner.nvim",
    event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-notify",
    },
    -- your opts go here
    opts = {
      command = {
        dev = {
          start = "NpmRunDev",
          stop = "NpmStopDev",
          cmd = "npm run dev",
        },
        prod = {
          start = "NpmStart",
          stop = "NpmStop",
          cmd = "npm start",
        },
      },
      opt = {
        show_mapping = "<leader>nm",
        hide_mapping = "<leader>nh",
        width = 70,
        height = 20,
      },
    },
    keys = {
      { "<leader>n", "", desc = "  Npm" },
    },
    config = function(_, opts)
      require("npm-runner").setup(opts.command, opts.opt)
    end,
  },
}


return M
