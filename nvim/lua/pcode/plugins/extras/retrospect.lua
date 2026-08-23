-- ════════════════════════════════════════════════════════════════════════════
-- retrospect.nvim — session manager (mrquantumcodes/retrospect.nvim)
-- Simpan set file yang lagi kebuka jadi "session", lalu restore kapan saja.
-- Berguna saat pindah task / tutup nvim tapi mau balik ke tata letak file semula.
-- Zero dependency. Aktif via flag: pcode.extras.retrospect = true (default.lua)
-- Grup keymap: <leader>\  (s=save, l=load/pilih, d=delete, c=config)
-- Semua command juga terdaftar di Commander hub → <leader>fk (cat: session)
-- ════════════════════════════════════════════════════════════════════════════
return {
  "mrquantumcodes/retrospect.nvim",
  cmd = { "SessionSave", "SessionLoad", "SessionDelete", "SessionConfig" },
  keys = {
    { "<leader>\\", nil, desc = " 󰆓 Session (retrospect)" },
    {
      "<leader>\\s",
      function()
        vim.cmd("SessionSave")
        -- mksession set vim.v.this_session saat sukses; kalau kosong = ditolak (mis. di config dir)
        if vim.v.this_session ~= "" then
          vim.notify("Session tersimpan → " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~"), vim.log.levels.INFO)
        else
          vim.notify("Session TIDAK tersimpan (cwd di folder config nvim?)", vim.log.levels.WARN)
        end
      end,
      desc = "Session: simpan file yang kebuka",
    },
    { "<leader>\\l", "<cmd>SessionLoad<cr>", desc = "Session: buka/pilih session" },
    { "<leader>\\d", "<cmd>SessionDelete<cr>", desc = "Session: hapus session" },
    { "<leader>\\c", "<cmd>SessionConfig<cr>", desc = "Session: konfigurasi" },
  },
  config = function()
    require("retrospect").setup({
      -- keymap internal dimatikan; keymap diatur via lazy `keys` di atas
      -- supaya punya desc/grup which-key & konsisten dengan config lain.
      save_key = "",
      load_key = "",
      autosave = false, -- set true kalau mau auto-save tiap kali :w
    })
  end,
}
