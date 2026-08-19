# Panduan Struktur Project + Cara Pasang LSP/Framework/Plugin

Dokumen ini menjelaskan alur config Neovim kamu (`nvim-lazy`) agar setup coding tetap aman, rapi, dan konsisten.

## 1) Struktur config yang dipakai

Urutan load utama:

1. `init.lua`
2. `lua/pcode/core/init.lua`
3. `lua/pcode/user/default.lua`
4. `lua/pcode/config/lazy_lib.lua`

Intinya:

- `pcode.user.default` memuat setting dasar (`options`, `autocmd`, `keymaps`).
- `pcode.plugins._default` berisi saklar utama:
  - `pcode.lang` (aktif/nonaktif modul bahasa)
  - `pcode.extras` (fitur tambahan)
  - `pcode.themes`
- `lazy_lib.lua` akan auto-import:
  - `pcode.plugins.*` (plugin inti)
  - `pcode.plugins.theme.*` (theme aktif)
  - `pcode.plugins.extras.*` (extras aktif)
  - `pcode.plugins.lang.*` (modul bahasa aktif)
  - `pcode.user.custom` (override final)

## 2) Komponen penting untuk dev nyaman

- LSP manager: `williamboman/mason-lspconfig.nvim` + `neovim/nvim-lspconfig`
- Auto setup LSP: `pojokcodeid/auto-lsp.nvim` (dipanggil di `plugins/_lsp.lua`)
- Formatter: `pojokcodeid/auto-conform.nvim` + `stevearc/conform.nvim`
- Linter: `pojokcodeid/auto-lint.nvim` + `mfussenegger/nvim-lint`
- Parser syntax: `nvim-treesitter/nvim-treesitter`
- Completion: `hrsh7th/nvim-cmp` + `cmp-nvim-lsp`

## 3) Cara mengaktifkan bahasa (paling aman)

Edit file:

`lua/pcode/plugins/_default.lua`

Contoh:

```lua
pcode.lang = {
  javascript = true,
  python = true,
  tailwind = true,
  pine = true,
}
```

Kalau `true`, maka file `lua/pcode/plugins/lang/<nama>.lua` ikut di-load otomatis.

## 4) Pola isi file `lang/<nama>.lua`

Umumnya 1 modul bahasa berisi:

1. Tambah parser Treesitter
2. Tambah server LSP via Mason LSP
3. Tambah formatter
4. Tambah linter (opsional)
5. Tool tambahan framework (opsional, misalnya neotest/dap)

Contoh pola minimal:

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "javascript", "typescript" })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "ts_ls", "eslint" })
    end,
  },
  {
    "pojokcodeid/auto-conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "prettier" })
      opts.formatters_by_ft.javascript = { "prettier" }
    end,
  },
}
```

## 5) Menambah bahasa baru dari nol

1. Buat file: `lua/pcode/plugins/lang/<bahasa>.lua`
2. Isi dengan pola pada bagian 4.
3. Aktifkan di `pcode.lang.<bahasa> = true` pada `_default.lua`.
4. Buka Neovim, jalankan:
   - `:Lazy sync`
   - `:Mason`
5. Verifikasi:
   - `:LspInfo`
   - `:Mason`
   - coba format manual: `<leader>lF`

## 6) Menambah plugin umum (bukan spesifik bahasa)

Pilih lokasi sesuai scope:

- Global/core plugin: `lua/pcode/plugins/*.lua`
- Extra opsional: `lua/pcode/plugins/extras/<nama>.lua` lalu aktifkan di `pcode.extras`
- Override/penyesuaian akhir: `lua/pcode/user/custom.lua`

Tips aman:

- Jangan ubah banyak file sekaligus.
- Tambah satu plugin, test, baru lanjut.
- Untuk perubahan diagnostic/UI LSP global, taruh di `pcode/user/custom.lua`.

## 7) Best practice "aman dan nyaman"

1. Pisahkan config per bahasa di `plugins/lang/*`.
2. Gunakan `ensure_installed` agar tool auto-terpasang.
3. Hindari duplikasi formatter/linter untuk filetype yang sama.
4. Simpan override lintas bahasa di `user/custom.lua`.
5. Cek health rutin:
   - `:checkhealth`
   - `:LspInfo`
   - `:MasonLog` jika install gagal.

## 8) Troubleshooting cepat

- LSP tidak attach:
  - pastikan server ada di `ensure_installed`
  - cek filetype (`:set filetype?`)
  - cek root project (buka nvim dari root project)
- Formatter tidak jalan:
  - cek `opts.formatters_by_ft.<filetype>`
  - cek tool formatter sudah terinstall di Mason
- Parser Treesitter error:
  - cek nama parser valid
  - jalankan `:TSUpdate`

## 9) Contoh PineScript (sudah siap dipakai)

Di config ini, PineScript dipasang lewat:

- `lua/pcode/plugins/lang/pine.lua`
- flag aktif: `pcode.lang.pine = true` di `lua/pcode/user/default.lua`

Plugin yang dipakai:

- `kaiiserni/pinescript.nvim`
- dependency: `neovim/nvim-lspconfig`

Opsi yang dipakai:

- `lsp.enabled = true`
- `lsp.auto_install = true`
- `treesitter.enabled = true`
- `treesitter.auto_install = true`

---

Kalau kamu mau, next saya bisa bikinkan template siap pakai untuk bahasa/framework spesifik (misal Vue, Svelte, NestJS, Flutter, atau Laravel full workflow).
