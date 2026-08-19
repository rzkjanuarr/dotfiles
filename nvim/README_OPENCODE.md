# 🚀 OpenCode Keymaps & Guide

Panduan cepat penggunaan OpenCode dengan konfigurasi `snacks.terminal` sebagai sidekick kanan.

## 🛠 Interaksi Utama

| Keymap       | Mode     | Deskripsi                                              |
| ------------ | -------- | ------------------------------------------------------ |
| `<leader>oa` | `n`, `x` | **Ask**: Tanya AI tentang file/konteks ini (`@this`)   |
| `<leader>os` | `n`, `x` | **Select**: Pilih aksi atau prompt yang tersedia       |
| `<leader>ot` | `n`, `t` | **Toggle**: Buka/Tutup Sidekick OpenCode di sisi kanan |

## 📝 Operator (Menambahkan Kode)

Gunakan mode operator seperti perintah `y` atau `d` bawaan Vim.

| Keymap       | Deskripsi                                                           |
| ------------ | ------------------------------------------------------------------- |
| `go{motion}` | Tambahkan range kode ke prompt (Contoh: `goip` untuk satu paragraf) |
| `goo`        | Tambahkan baris ini (current line) ke prompt                        |

## 📜 Navigasi Chat (Scroll)

Scroll isi chat di terminal tanpa pindah fokus dari editor.

| Keymap    | Deskripsi                               |
| --------- | --------------------------------------- |
| `<S-C-u>` | Scroll Up (Setengah halaman ke atas)    |
| `<S-C-d>` | Scroll Down (Setengah halaman ke bawah) |

## 🔍 Integrasi Snacks Picker

Saat berada di dalam jendela **Snacks Picker** (File search, Grep, dll):

| Keymap  | Deskripsi                                         |
| ------- | ------------------------------------------------- |
| `<A-a>` | Kirim item/file yang dipilih langsung ke OpenCode |

---

_Catatan: Konfigurasi ini menggunakan `snacks.terminal` dengan lebar 30% di sisi kanan._
