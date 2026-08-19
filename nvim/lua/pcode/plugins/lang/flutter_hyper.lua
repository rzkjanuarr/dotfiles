-- Flutter Hyper Extension (port ke Neovim)
-- Reimplementasi fitur dari VS Code extension "denyocr.flutter-hyper-extension"
-- yang tidak ditutupi oleh dart LSP:
--   1. Focus navigation (focusToBuild / initState / dispose / appBar / body / bottomNavigationBar)
--   2. Shortcut wrap-widget lewat LSP code action (Column/Row/Center/Padding/dll native di dartls)
--
-- Snippet-nya di-load terpisah lewat mysnippets/flutter/*.json (LuaSnip from_vscode),
-- karena package.json mysnippets sudah didaftarkan language "dart".
--
-- Diaktifkan lewat: pcode.lang.flutter = true (di lua/pcode/user/default.lua)

-- ── Focus navigation ────────────────────────────────────────────────────────
-- Port dari document_helper.js: cari baris TERAKHIR yang mengandung `needle`,
-- pindahkan kursor ke sana, dan reveal di bagian atas layar (zt).
local function focus_to_contains(needle)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local target = nil
  for i, line in ipairs(lines) do
    if line:find(needle, 1, true) then
      target = i -- 1-based; simpan yang terakhir match (sama seperti extension)
    end
  end
  if not target then
    vim.notify("Flutter Hyper: '" .. needle .. "' tidak ditemukan", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_win_set_cursor(0, { target, 0 })
  vim.cmd("normal! ^")
  vim.cmd("normal! zt") -- reveal di atas (mirip TextEditorRevealType.AtTop)
end

-- Wrap widget: delegasi ke dart LSP (dartls menyediakan "Wrap with ...").
local function wrap_widget()
  vim.lsp.buf.code_action({
    filter = function(action)
      local title = (action.title or ""):lower()
      return title:find("wrap with") ~= nil
    end,
    apply = false,
  })
end

local function setup_keymaps(bufnr)
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end
  map("<leader>fb", function() focus_to_contains(" build(") end, "Flutter: focus build()")
  map("<leader>fi", function() focus_to_contains(" initState(") end, "Flutter: focus initState()")
  map("<leader>fd", function() focus_to_contains(" dispose(") end, "Flutter: focus dispose()")
  map("<leader>fa", function() focus_to_contains(" appBar:") end, "Flutter: focus appBar:")
  map("<leader>fy", function() focus_to_contains(" body:") end, "Flutter: focus body:")
  map("<leader>fn", function() focus_to_contains(" bottomNavigationBar:") end, "Flutter: focus bottomNavigationBar:")
  map("<leader>fw", wrap_widget, "Flutter: wrap widget (LSP)")
end

-- ── FVM resolver ────────────────────────────────────────────────────────────
-- Menentukan lokasi Flutter SDK dengan urutan prioritas:
--   1. .fvm/flutter_sdk pada project (FVM per-project)  -> paling akurat
--   2. ~/fvm/default (FVM global, symlink ke versi aktif)
--   3. nil -> biarkan flutter-tools cari `flutter`/`dart` di PATH (default)
local function resolve_flutter()
  -- 1. FVM lokal project. Cari ke atas dari cwd sampai ketemu .fvm/flutter_sdk
  local found = vim.fs.find(".fvm", {
    path = vim.fn.getcwd(),
    upward = true,
    type = "directory",
  })
  if found and found[1] then
    local sdk = found[1] .. "/flutter_sdk"
    if vim.fn.isdirectory(sdk) == 1 then
      return {
        fvm = true,
        flutter_lookup_cmd = nil,
        -- flutter-tools bisa diarahkan lewat flutter_path (binary flutter)
        flutter_path = sdk .. "/bin/flutter",
      }
    end
  end

  -- 2. FVM global default
  local home = vim.env.HOME or vim.fn.expand("~")
  local global_sdk = home .. "/fvm/default"
  if vim.fn.isdirectory(global_sdk) == 1 then
    return {
      fvm = true,
      flutter_path = global_sdk .. "/bin/flutter",
    }
  end

  -- 3. fallback ke PATH
  return { fvm = false }
end

-- ── lazy.nvim spec ──────────────────────────────────────────────────────────
return {
  -- treesitter parser dart
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "dart" })
    end,
  },
  -- LSP dartls (via flutter-tools untuk integrasi penuh Flutter)
  -- + keymap focus-navigation per-buffer dart (fitur khas extension)
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    dependencies = { "nvim-lua/plenary.nvim" },
    init = function()
      -- autocmd dipasang lebih awal agar keymap aktif untuk setiap buffer dart,
      -- termasuk buffer dart pertama yang memicu ft = "dart".
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dart",
        callback = function(args)
          setup_keymaps(args.buf)
        end,
        desc = "Flutter Hyper focus-navigation keymaps",
      })
    end,
    opts = function()
      local fl = resolve_flutter()
      local opts = {
        lsp = {
          color = { enabled = true },
        },
      }
      if fl.fvm then
        -- Bila project punya .fvm lokal, biarkan flutter-tools pakai `fvm flutter`
        -- (menghormati versi per-project). Jika hanya global, arahkan langsung ke binary.
        local has_local_fvm = vim.fs.find(".fvm", {
          path = vim.fn.getcwd(),
          upward = true,
          type = "directory",
        })[1] ~= nil
        if has_local_fvm then
          opts.fvm = true
        else
          opts.flutter_path = fl.flutter_path
        end
      end
      return opts
    end,
  },
}

