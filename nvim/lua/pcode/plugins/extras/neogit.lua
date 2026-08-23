-- ════════════════════════════════════════════════════════════════════════════
-- neogit — panel Git satu layar ala VSCode Source Control
-- Isi panel (tiap grup bisa expand/collapse pakai Tab):
--   Head:              branch + commit terakhir
--   Unstaged changes   ← perubahan belum di-stage
--   Staged changes     ← sudah di-stage
--   Stashes
--   Recent commits     ← HISTORY COMMIT
-- Aktif via flag: pcode.extras.neogit = true (default.lua)
-- Semua command terdaftar di Commander hub → <leader>fk (cat: core)
-- ════════════════════════════════════════════════════════════════════════════
return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "Neogit", "NeogitCommit", "NeogitLogCurrent" },
  keys = {
    { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit: panel git (status + history)" },
    { "<leader>gh", "<cmd>Neogit log<cr>", desc = "Neogit: history commit (semua)" },
    { "<leader>gf", "<cmd>Neogit push<cr>", desc = "Neogit: push" },
    -- Cari commit berdasarkan pesan/ID. SENGAJA tidak bisa checkout dari sini:
    -- Enter & Ctrl-y sama-sama menyalin ID saja, biar tidak kepencet checkout
    -- lalu masuk detached HEAD. Checkout tetap bisa via <leader>gn → b (branch).
    {
      "<leader>gi",
      function()
        local actions = require("telescope.actions")
        local state = require("telescope.actions.state")
        local function salin_id(bufnr)
          local entry = state.get_selected_entry()
          if not entry or not entry.value then
            return
          end
          vim.fn.setreg("+", entry.value)
          vim.fn.setreg('"', entry.value)
          actions.close(bufnr)
          vim.notify("ID commit disalin: " .. entry.value, vim.log.levels.INFO)
        end
        require("telescope.builtin").git_commits({
          prompt_title = "Cari commit (Enter / Ctrl-y = salin ID)",
          attach_mappings = function(_, map)
            -- ganti aksi default (checkout) jadi salin ID
            actions.select_default:replace(salin_id)
            map({ "i", "n" }, "<C-y>", salin_id)
            return true
          end,
        })
      end,
      desc = "Neogit: cari commit / salin ID",
    },
  },
  opts = {
    -- panel utama: floating di tengah layar
    kind = "floating",
    -- menu/popup (push, log, commit, dll) juga floating
    popup = { kind = "floating" },
    commit_editor = { kind = "floating" },
    commit_select_view = { kind = "floating" },
    commit_view = { kind = "floating" },
    log_view = { kind = "floating" },
    rebase_editor = { kind = "floating" },
    reflog_view = { kind = "floating" },
    merge_editor = { kind = "floating" },
    description_editor = { kind = "floating" },
    preview_buffer = { kind = "floating" },
    graph_style = "unicode",
    -- jumlah commit yang ditampilkan di bagian "Recent commits"
    status = {
      recent_commit_count = 15,
      mode_padding = 3,
    },
    signs = {
      -- penanda expand/collapse tiap grup
      hunk = { "", "" },
      item = { "", "" },
      section = { "", "" },
    },
    mappings = {
      status = {
        -- klik mouse: buka/tutup grup atau lihat isi item
        ["<2-LeftMouse>"] = "Toggle",
      },
    },
  },
}
