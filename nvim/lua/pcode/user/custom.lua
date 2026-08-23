return {
  -- overidse dashboard
  {
    "goolord/alpha-nvim",
    opts = {
      dash_model = {
        [[     ██╗██╗   ██╗███████╗████████╗    ██████╗  ██████╗     ██╗████████╗██╗ ]],
        [[     ██║██║   ██║██╔════╝╚══██╔══╝    ██╔══██╗██╔═══██╗    ██║╚══██╔══╝██║ ]],
        [[     ██║██║   ██║███████╗   ██║       ██║  ██║██║   ██║    ██║   ██║   ██║ ]],
        [[██   ██║██║   ██║╚════██║   ██║       ██║  ██║██║   ██║    ██║   ██║   ╚═╝ ]],
        [[╚█████╔╝╚██████╔╝███████║   ██║       ██████╔╝╚██████╔╝    ██║   ██║   ██╗ ]],
        [[ ╚════╝  ╚═════╝ ╚══════╝   ╚═╝       ╚═════╝  ╚═════╝     ╚═╝   ╚═╝   ╚═╝ ]],
      },
    },
  },
  -- overide lualine
  {
    "pojokcodeid/auto-lualine.nvim",
    opts = {
      -- for more options check out https://github.com/pojokcodeid/auto-lualine.nvim
      setColor = "auto",
      setOption = "parallelogram",
      setMode = 5,
    },
  },
  -- overide formatting
  {
    "pojokcodeid/auto-conform.nvim",
    opts = {
      format_on_save = true,
      format_timeout_ms = 5000,
    },
  },
  -- install treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "lua", "c" })
    end,
  },
  -- install mason (lsp, dap, linters, formatters)
  {
    "williamboman/mason.nvim",
    -- opts = { ensure_installed = { "stylua" } },
  },
  -- overide lsp config
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.skip_config, {})
      opts.virtual_text = false
      vim.diagnostic.config({ virtual_lines = { current_line = true } })
      -- sample custom diagnostic icon
      vim.diagnostic.config({
        underline = false,
        virtual_text = false,
        update_in_insert = false,
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      })
    end,
  },
  -- add whichkey mappings
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.mappings = opts.mappings or {}
      vim.list_extend(opts.mappings, {
        { "<leader>h", "<cmd>nohlsearch<CR>", desc = "󱪿 No Highlight", mode = "n" },
      })
    end,
  },
  -- overide telescope
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      -- JANGAN timpa find_files di sini: tuning-nya (fd + exclude .git) sudah
      -- diatur di plugins/telecope.lua. Menimpanya bikin isi .git muncul lagi
      -- dan hasil pencarian jadi penuh sampah.
      opts.pickers = opts.pickers or {}
      opts.pickers.live_grep = {
        theme = "dropdown",
        only_sort_text = true,
        additional_args = function()
          return { "--multiline" }
        end,
      }
    end,
  },
  -- add code runner
  {
    "CRAG666/code_runner.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.filetype, { go = "go run $fileName" })
    end,
  },
}
