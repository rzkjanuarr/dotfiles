return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      if vim.fn.executable("mcp-hub") ~= 1 then
        vim.schedule(function()
          vim.notify(
            "mcp-hub binary tidak ditemukan. Install dulu: npm install -g mcp-hub@latest",
            vim.log.levels.WARN
          )
        end)
        return
      end
      require("mcphub").setup()
    end,
  },
}
