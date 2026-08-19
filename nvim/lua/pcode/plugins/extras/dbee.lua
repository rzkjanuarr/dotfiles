return {
  "kndndrj/nvim-dbee",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function()
    require("dbee").install("curl")
  end,
  config = function()
    require("dbee").setup({
      -- ─── Sources: koneksi database ─────────────────────
      sources = {
        -- File source: koneksi disimpan permanen di file JSON
        require("dbee.sources").FileSource:new(
          vim.fn.stdpath("data") .. "/dbee/connections.json"
        ),
        -- Env source: baca dari environment variable (aman, no plaintext)
        require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
      },

      -- ─── Extra helpers per DB type ─────────────────────
      extra_helpers = {
        ["mysql"] = {
          ["Show Tables"] = "SHOW TABLES",
          ["Show Databases"] = "SHOW DATABASES",
          ["Describe Table"] = "DESCRIBE {{ .Table }}",
        },
        ["postgres"] = {
          ["List Tables"] = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'",
          ["Describe Table"] = "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '{{ .Table }}'",
        },
      },

      -- ─── Drawer (sidebar kiri) ─────────────────────────
      drawer = {
        disable_candies = false, -- icon-icon
        mappings = {
          { key = "<CR>",  mode = "n", action = "action_1" }, -- open/select
          { key = "o",     mode = "n", action = "action_1" },
          { key = "l",     mode = "n", action = "action_1" },
          { key = "cw",    mode = "n", action = "action_2" }, -- rename
          { key = "dd",    mode = "n", action = "action_3" }, -- delete
          { key = "<C-r>", mode = "n", action = "refresh" },
        },
      },

      -- ─── Editor (tempat nulis query) ───────────────────
      editor = {
        mappings = {
          { key = "BB", mode = "v", action = "run_selection" }, -- run selected query
          { key = "BB", mode = "n", action = "run_file" },      -- run whole file
        },
      },

      -- ─── Result (tampilan hasil query) ─────────────────
      result = {
        mappings = {
          { key = "<C-n>", mode = "n", action = "page_next" },
          { key = "<C-p>", mode = "n", action = "page_prev" },
          { key = "<C-k>", mode = "n", action = "page_last" },
          { key = "<C-j>", mode = "n", action = "page_first" },
          { key = "yaj",   mode = "n", action = "yank_current_json" },
          { key = "yac",   mode = "n", action = "yank_current_csv" },
        },
      },
    })

    -- ─── Keymaps global ────────────────────────────────
    vim.keymap.set("n", "<leader>Wb", function() require("dbee").toggle() end, { desc = "Toggle DBee" })
    vim.keymap.set("n", "<leader>Wo", function() require("dbee").open() end,   { desc = "Open DBee" })
    vim.keymap.set("n", "<leader>Wc", function() require("dbee").close() end,  { desc = "Close DBee" })
  end,
}
