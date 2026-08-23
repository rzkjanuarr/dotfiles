-- ════════════════════════════════════════════════════════════════════════════
-- claudecode.nvim — integrasi Claude Code CLI (coder/claudecode.nvim)
-- Sidekick AI di dalam nvim; terminal Claude + kirim buffer/seleksi + review diff.
-- Prasyarat: Claude Code CLI terpasang (`claude`), snacks.nvim (sudah aktif).
-- Aktif via flag: pcode.extras.claudecode = true (default.lua)
-- Semua command juga terdaftar di Commander hub → <leader>fk (cat: claude)
-- ════════════════════════════════════════════════════════════════════════════
-- ── Bersihkan lock file yatim ───────────────────────────────────────────────
-- Tiap nvim punya PORT SENDIRI, jadi Claude di beberapa nvim BISA jalan
-- bersamaan (mis. ~/dotfiles dan ~/project lain) tanpa saling ganggu.
-- Yang jadi masalah cuma lock file sisa nvim yang mati paksa (crash/kill).
-- Lock menyimpan `pid`, jadi kita cuma hapus yang prosesnya sudah tidak ada.
local function bersihkan_lock_yatim()
  local dir = vim.fn.expand("~/.claude/ide")
  if vim.fn.isdirectory(dir) == 0 then
    return 0
  end
  local terhapus = 0
  for _, file in ipairs(vim.fn.glob(dir .. "/*.lock", false, true)) do
    local ok, isi = pcall(vim.fn.readfile, file)
    if ok and isi and #isi > 0 then
      local ok2, data = pcall(vim.json.decode, table.concat(isi, "\n"))
      local pid = ok2 and data and data.pid
      -- Cek proses masih hidup. Sinyal 0 hanya memeriksa keberadaan, TIDAK membunuh.
      -- Hapus hanya bila jelas-jelas mati; kalau ragu, biarkan (jangan sampai
      -- lock sesi yang sedang aktif ikut kebuang).
      if type(pid) == "number" then
        local hidup = vim.uv.kill(pid, 0) == 0
        if not hidup then
          vim.fn.delete(file)
          terhapus = terhapus + 1
        end
      end
    end
  end
  return terhapus
end

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = function(_, opts)
    require("claudecode").setup(opts)
    bersihkan_lock_yatim()

    -- `auto_start = true` bikin server sudah hidup sejak nvim dibuka, jadi
    -- :ClaudeCodeStart selalu mengeluh "already running on port ...".
    -- Ganti jadi: kalau sudah jalan → langsung buka terminalnya (bukan warning).
    vim.api.nvim_create_user_command("ClaudeCodeStart", function()
      local cc = require("claudecode")
      if cc.state and cc.state.server then
        vim.cmd("ClaudeCode")
      else
        cc.start()
      end
    end, { desc = "Start Claude Code (buka terminal bila server sudah jalan)" })

    vim.api.nvim_create_user_command("ClaudeCodeCleanLocks", function()
      local n = bersihkan_lock_yatim()
      vim.notify(
        n > 0 and ("Lock yatim dibersihkan: " .. n .. " file") or "Tidak ada lock yatim (semua sesi sehat)",
        vim.log.levels.INFO
      )
    end, { desc = "Hapus lock file Claude sisa nvim yang mati paksa" })
  end,
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeStatus",
    "ClaudeCodeStart",
    "ClaudeCodeStop",
    "ClaudeCodeOpen",
    "ClaudeCodeClose",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeCloseAllDiffs",
  },
  keys = {
    { "<leader>a", nil, desc = " 󰧑 AI / Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle terminal" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: fokus terminal" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: resume sesi" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: lanjut sesi terakhir" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: pilih model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: tambah buffer ini" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: kirim seleksi" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Claude: tambah file dari tree",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
    },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: terima diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: tolak diff" },
    { "<leader>ax", "<cmd>ClaudeCodeStop<cr>", desc = "Claude: stop server" },
    { "<leader>ai", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude: status koneksi" },
  },
}
