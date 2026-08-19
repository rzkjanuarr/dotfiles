return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  dependencies = { "folke/snacks.nvim" },
  config = function()
    -- ─── Sidekick kanan pakai snacks.terminal ──────────
    local opencode_cmd = "opencode"
    ---@type snacks.terminal.Opts
    local snacks_terminal_opts = {
      win = {
        position = "right", -- <== sidekick kanan
        width = 0.3, -- 30% lebar layar
        enter = false, -- fokus tetap di editor
        on_win = function(win)
          require("opencode.terminal").setup(win.win)
        end,
      },
    }

    ---@type opencode.Opts
    vim.g.opencode_opts = {
      lsp = { enabled = true },
      server = {
        start = function()
          require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
        end,
        stop = function()
          require("snacks.terminal").get(opencode_cmd, snacks_terminal_opts):close()
        end,
        toggle = function()
          require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
        end,
      },
    }

    vim.o.autoread = true

    -- ─── Keymaps ───────────────────────────────────────
    vim.keymap.set({ "n", "x" }, "<leader>oa",
      function() require("opencode").ask("@this: ", { submit = true }) end,
      { desc = "Ask opencode" })

    vim.keymap.set({ "n", "x" }, "<leader>os",
      function() require("opencode").select() end,
      { desc = "Select opencode action" })

    vim.keymap.set({ "n", "t" }, "<leader>ot",
      function() require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts) end,
      { desc = "Toggle opencode sidekick" })

    vim.keymap.set({ "n", "x" }, "go",
      function() return require("opencode").operator("@this ") end,
      { desc = "Add range to opencode", expr = true })

    vim.keymap.set("n", "goo",
      function() return require("opencode").operator("@this ") .. "_" end,
      { desc = "Add line to opencode", expr = true })

    vim.keymap.set("n", "<S-C-u>",
      function() require("opencode").command("session.half.page.up") end,
      { desc = "Scroll opencode up" })

    vim.keymap.set("n", "<S-C-d>",
      function() require("opencode").command("session.half.page.down") end,
      { desc = "Scroll opencode down" })
  end,
}
