return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "pascal" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- Kita setup pasls secara manual. 
      -- Ini akan jalan jika binary 'pasls' ada di PATH sistem kamu.
      local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
      if lspconfig_ok then
        lspconfig.pasls.setup({
          -- cmd = { "pasls" }, -- ganti path jika binary ada di lokasi spesifik
          filetypes = { "pascal", "pp", "inc" },
        })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      -- Tambahkan PascalRun command
      vim.api.nvim_create_user_command("PascalRun", function()
        local filename = vim.fn.expand("%:p")
        local output = vim.fn.expand("%:p:r")
        if not filename:match("%.pas$") and not filename:match("%.pp$") then
          vim.notify("File ini bukan file Pascal.", vim.log.levels.WARN, { title = "PascalRun" })
          return
        end

        local ok, toggleterm = pcall(require, "toggleterm.terminal")
        if not ok then
          vim.notify("Plugin 'toggleterm' tidak ditemukan.", vim.log.levels.ERROR)
          return
        end

        local Terminal = toggleterm.Terminal
        local cmd = "fpc " .. filename .. " && " .. output
        if vim.fn.has("win32") == 1 then
          cmd = "fpc " .. filename .. " && " .. output .. ".exe"
        end

        local pascal_runner = Terminal:new({
          cmd = cmd,
          direction = "float",
          close_on_exit = false,
          hidden = true,
        })

        pascal_runner:toggle()
      end, { desc = "Compile and Run Pascal file using fpc" })
    end,
  },
}
