-- ════════════════════════════════════════════════════════════════════════════
-- muslim.nvim — jadwal salat + integrasi lualine
-- Lokasi: Bandung/Jakarta (Asia/Jakarta, UTC+7)
--   latitude  = -6.913875983861126
--   longitude =  107.60628218175617
-- Aktif via flag: pcode.extras.muslim = true (default.lua)
-- Statusline dikelola auto-lualine.nvim, jadi komponen prayer_time disisipkan
-- non-destruktif lewat require("lualine").get_config() setelah lualine ter-setup.
-- ════════════════════════════════════════════════════════════════════════════

-- Sisipkan komponen muslim.prayer_time ke lualine_x (idempotent).
local function inject_lualine()
  local ok_l, lualine = pcall(require, "lualine")
  if not ok_l then return end
  local ok_m, muslim = pcall(require, "muslim")
  if not ok_m then return end

  local cfg = lualine.get_config()
  cfg.sections = cfg.sections or {}
  cfg.sections.lualine_x = cfg.sections.lualine_x or {}

  -- cegah dobel bila fungsi ini dipanggil lagi (colorscheme change dsb)
  for _, comp in ipairs(cfg.sections.lualine_x) do
    if type(comp) == "table" and comp.id == "muslim.nvim" then
      return
    end
  end

  table.insert(cfg.sections.lualine_x, 1, {
    muslim.prayer_time,
    id = "muslim.nvim",
    color = { fg = "#7aa2f7" }, -- biru; aman untuk theme gelap
  })
  lualine.setup(cfg)
end

return {
  {
    "tajirhas9/muslim.nvim",
    event = { "VeryLazy" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-lualine/lualine.nvim",
    },
    config = function()
      require("muslim").setup({
        latitude       = -6.913875983861126,
        longitude      = 107.60628218175617,
        timezone       = "Asia/Jakarta", -- dekoratif; kalkulasi pakai utc_offset
        utc_offset     = 7,              -- Asia/Jakarta = GMT+7
        refresh        = 5,              -- update tiap 5 menit
        school         = "hanafi",
        method         = "MWL",
        time_format    = "24H",
        countdown_only = false,
      })

      -- sisipkan ke statusline; tunda agar auto-lualine sudah setup dulu
      vim.schedule(inject_lualine)

      -- pasang ulang tiap ganti colorscheme (auto-lualine re-setup lualine)
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.schedule(inject_lualine)
        end,
        desc = "muslim.nvim: re-inject prayer_time ke lualine",
      })
    end,
  },
}
