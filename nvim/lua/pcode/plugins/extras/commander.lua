-- ════════════════════════════════════════════════════════════════════════════
-- commander.nvim — hub command terpusat (searchable via telescope)
-- Buka: <leader>fk  atau  :Telescope commander
-- Semua command/tool custom didaftarkan di sini dengan kategori (CAT).
-- Aktif via flag: pcode.extras.commander = true (default.lua)
-- ════════════════════════════════════════════════════════════════════════════
return {
  "FeiyouG/commander.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = { "Telescope" },
  keys = {
    { "<leader>fk", "<CMD>Telescope commander<CR>", mode = "n", desc = "Commander: hub command" },
    -- pemicu load untuk file-ops (biar keymap langsung jalan tanpa buka commander dulu)
    { "<leader>fN", "<CMD>NewFile<CR>", mode = "n", desc = "File: buat baru" },
    { "<leader>fD", "<CMD>DeleteFile<CR>", mode = "n", desc = "File: hapus" },
    { "<leader>fR", "<CMD>RenameFile<CR>", mode = "n", desc = "File: rename" },
    -- window & tab
    { "<leader>-", "<CMD>split<CR>", mode = "n", desc = "Window: split horizontal" },
    { "<leader>|", "<CMD>vsplit<CR>", mode = "n", desc = "Window: split vertical" },
    { "<leader>tn", "<CMD>tabnew<CR>", mode = "n", desc = "Tab: baru" },
    { "<leader>tc", "<CMD>tabclose<CR>", mode = "n", desc = "Tab: tutup" },
    { "<leader>tl", "<CMD>tabnext<CR>", mode = "n", desc = "Tab: berikutnya" },
    { "<leader>tp", "<CMD>tabprevious<CR>", mode = "n", desc = "Tab: sebelumnya" },
    -- search
    { "<leader>sb", "<CMD>Telescope current_buffer_fuzzy_find<CR>", mode = "n", desc = "Search: buffer ini" },
    { "<leader>sw", "<CMD>Telescope grep_string<CR>", mode = "n", desc = "Search: kata di cursor" },
  },
  config = function()
    local commander = require("commander")

    commander.setup({
      components = { "DESC", "KEYS", "CAT", "CMD" },
      sort_by = { "CAT", "DESC", "KEYS", "CMD" },
      separator = " │ ",
      auto_replace_desc_with_cmd = true,
      prompt_title = "󱓞 Commander",
      integration = {
        telescope = {
          enable = true,
          theme = require("telescope.themes").commander,
        },
        lazy = { enable = true },
      },
    })

    -- ── User command file-ops (buat/hapus/rename/copy-path) ──────────────────
    local uc = vim.api.nvim_create_user_command

    uc("NewFile", function()
      local dir = vim.fn.expand("%:p:h")
      if dir == "" then dir = vim.fn.getcwd() end
      vim.ui.input({ prompt = "File baru: ", default = dir .. "/", completion = "file" }, function(path)
        if not path or path == "" then return end
        local d = vim.fn.fnamemodify(path, ":h")
        if vim.fn.isdirectory(d) == 0 then vim.fn.mkdir(d, "p") end
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        vim.cmd("write")
        vim.notify("Dibuat: " .. path, vim.log.levels.INFO)
      end)
    end, { desc = "Buat file baru lalu buka" })

    uc("DeleteFile", function()
      local path = vim.fn.expand("%:p")
      if path == "" then
        vim.notify("Buffer tidak punya file di disk.", vim.log.levels.WARN)
        return
      end
      vim.ui.select({ "Ya, hapus", "Batal" }, { prompt = "Hapus file? " .. path }, function(choice)
        if choice ~= "Ya, hapus" then return end
        local ok, err = os.remove(path)
        if ok then
          vim.api.nvim_buf_delete(0, { force = true })
          vim.notify("Dihapus: " .. path, vim.log.levels.INFO)
        else
          vim.notify("Gagal hapus: " .. tostring(err), vim.log.levels.ERROR)
        end
      end)
    end, { desc = "Hapus file yang sedang dibuka" })

    uc("RenameFile", function()
      local old = vim.fn.expand("%:p")
      if old == "" then
        vim.notify("Buffer tidak punya file di disk.", vim.log.levels.WARN)
        return
      end
      vim.ui.input({ prompt = "Rename ke: ", default = old, completion = "file" }, function(new)
        if not new or new == "" or new == old then return end
        local d = vim.fn.fnamemodify(new, ":h")
        if vim.fn.isdirectory(d) == 0 then vim.fn.mkdir(d, "p") end
        local ok, err = os.rename(old, new)
        if ok then
          vim.cmd("edit " .. vim.fn.fnameescape(new))
          vim.cmd("bdelete #")
          vim.notify("Rename → " .. new, vim.log.levels.INFO)
        else
          vim.notify("Gagal rename: " .. tostring(err), vim.log.levels.ERROR)
        end
      end)
    end, { desc = "Rename/pindah file yang dibuka" })

    uc("CopyFilePath", function()
      local path = vim.fn.expand("%:p")
      if path == "" then
        vim.notify("Buffer tidak punya file di disk.", vim.log.levels.WARN)
        return
      end
      vim.fn.setreg("+", path)
      vim.notify("Path disalin: " .. path, vim.log.levels.INFO)
    end, { desc = "Copy path absolut file aktif ke clipboard" })

    -- ── Daftar command terpusat ───────────────────────────────────────────────
    commander.add({
      -- Commander sendiri
      {
        desc = "Open Commander (hub semua command)",
        cmd = "<CMD>Telescope commander<CR>",
        keys = { "n", "<leader>fk" },
        set = false, -- keymap sudah di-set via lazy `keys` spec
        cat = "commander",
      },

      -- ── Flutter Hyper ──
      {
        desc = "Flutter Hyper: menu terpusat (generator/wrap/permission/open)",
        cmd = "<CMD>FlutterHyper<CR>",
        cat = "flutter",
      },
      {
        desc = "Flutter: generate core.dart",
        cmd = "<CMD>FlutterCore<CR>",
        cat = "flutter",
      },
      {
        desc = "Flutter: create module dari template",
        cmd = "<CMD>FlutterModule<CR>",
        cat = "flutter",
      },
      {
        desc = "Flutter: generate UDF snippet",
        cmd = "<CMD>FlutterUdf<CR>",
        cat = "flutter",
      },
      {
        desc = "Flutter: wrap widget (list ala hyper)",
        cmd = "<CMD>FlutterWrap<CR>",
        cat = "flutter",
      },
      {
        desc = "Flutter: add Android permission",
        cmd = "<CMD>FlutterPermission<CR>",
        cat = "flutter",
      },
      {
        desc = "Flutter: open file project (pubspec/manifest/gradle)",
        cmd = "<CMD>FlutterOpen<CR>",
        cat = "flutter",
      },

      -- ── Snippet ──
      {
        desc = "Snippet: simpan blok visual jadi snippet",
        cmd = "<CMD>SnippetSave<CR>",
        cat = "snippet",
      },

      -- ── Window & Tab ──
      {
        desc = "Window: split horizontal (bawah)",
        cmd = "<CMD>split<CR>",
        cat = "window",
      },
      {
        desc = "Window: split vertical (samping)",
        cmd = "<CMD>vsplit<CR>",
        cat = "window",
      },
      {
        desc = "Window: tutup window aktif",
        cmd = "<CMD>close<CR>",
        cat = "window",
      },
      {
        desc = "Window: samakan ukuran semua window",
        cmd = "<C-w>=",
        cat = "window",
      },
      {
        desc = "Window: pindah kiri/bawah/atas/kanan (<C-h/j/k/l>)",
        cmd = "<C-w>w",
        cat = "window",
      },
      {
        desc = "Tab: buka tab baru",
        cmd = "<CMD>tabnew<CR>",
        cat = "tab",
      },
      {
        desc = "Tab: tutup tab",
        cmd = "<CMD>tabclose<CR>",
        cat = "tab",
      },
      {
        desc = "Tab: tab berikutnya",
        cmd = "<CMD>tabnext<CR>",
        cat = "tab",
      },
      {
        desc = "Tab: tab sebelumnya",
        cmd = "<CMD>tabprevious<CR>",
        cat = "tab",
      },
      {
        desc = "Tab: pindah buffer aktif ke tab baru",
        cmd = "<CMD>tabnew %<CR>",
        cat = "tab",
      },

      -- ── File ops ──
      {
        desc = "File: buat file baru (input path)",
        cmd = "<CMD>NewFile<CR>",
        cat = "file",
      },
      {
        desc = "File: hapus file yang sedang dibuka",
        cmd = "<CMD>DeleteFile<CR>",
        cat = "file",
      },
      {
        desc = "File: rename/pindah file yang dibuka",
        cmd = "<CMD>RenameFile<CR>",
        cat = "file",
      },
      {
        desc = "File: copy path absolut file aktif ke clipboard",
        cmd = "<CMD>CopyFilePath<CR>",
        cat = "file",
      },

      -- ── Search & Replace ──
      {
        desc = "Search: teks di SEMUA file (live grep)",
        cmd = "<CMD>Telescope live_grep<CR>",
        keys = { "n", "R" },
        set = false, -- keymap sudah di-set di keymaps.lua
        cat = "search",
      },
      {
        desc = "Search: teks di SATU file (buffer ini)",
        cmd = "<CMD>Telescope current_buffer_fuzzy_find<CR>",
        cat = "search",
      },
      {
        desc = "Search: kata di bawah cursor (semua file)",
        cmd = "<CMD>Telescope grep_string<CR>",
        cat = "search",
      },
      {
        desc = "Replace: kata di SEMUA file (grug-far global)",
        cmd = function()
          require("grug-far").open({
            windowCreationCommand = "tabnew",
            staticTitle = " Global Search and Replace ",
          })
        end,
        cat = "search",
      },
      {
        desc = "Replace: kata di SATU file (grug-far, file ini)",
        cmd = function()
          require("grug-far").open({
            prefills = { paths = vim.fn.expand("%") },
            staticTitle = " Search and Replace (Current File) ",
          })
        end,
        keys = { "n", "<leader>sr" },
        set = false, -- keymap sudah di-set di keymaps.lua
        cat = "search",
      },

      -- ── Go ──
      { desc = "Go: build", cmd = "<CMD>GoBuild<CR>", cat = "go" },
      { desc = "Go: run", cmd = "<CMD>GoRun<CR>", cat = "go" },
      { desc = "Go: new file", cmd = "<CMD>GoNewFile<CR>", cat = "go" },
      { desc = "Go: new project", cmd = "<CMD>GoNewProject<CR>", cat = "go" },

      -- ── Pascal ──
      { desc = "Pascal: run", cmd = "<CMD>PascalRun<CR>", cat = "pascal" },

      -- ── LSP ──
      { desc = "LSP: status", cmd = "<CMD>LspStatus<CR>", cat = "lsp" },
      { desc = "LSP: capabilities", cmd = "<CMD>LspCapabilities<CR>", cat = "lsp" },
      { desc = "LSP: diagnostics", cmd = "<CMD>LspDiagnostics<CR>", cat = "lsp" },

      -- ── Treesitter ──
      { desc = "Treesitter: install info", cmd = "<CMD>TSInstallInfo<CR>", cat = "treesitter" },
      { desc = "Treesitter: installed parsers (uninstall)", cmd = "<CMD>TSIsInstalled<CR>", cat = "treesitter" },

      -- ── Misc ──
      { desc = "Open in browser", cmd = "<CMD>OpenBrowser<CR>", cat = "misc" },
      { desc = "Check breakpoints", cmd = "<CMD>CheckBP<CR>", cat = "misc" },
    }, {
      -- jangan set keymap dari sini (keymap sudah diatur di tempat masing-masing);
      -- kecuali entri yang punya `keys` eksplisit di atas.
      show = true,
    })
  end,
}
