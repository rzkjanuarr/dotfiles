# 🗄️ Database Management (DBee)

Panduan penggunaan asisten database `nvim-dbee` di Neovim kamu.

## 🛠 Interaksi Utama
| Keymap | Mode | Deskripsi |
| --- | --- | --- |
| **`<leader>Wb`** | `n` | **Toggle DBee**: Buka/Tutup antarmuka database |
| **`<leader>Wo`** | `n` | **Open DBee**: Membuka antarmuka database |
| **`<leader>Wc`** | `n` | **Close DBee**: Menutup antarmuka database |

---
*Catatan: Keymap diubah ke prefix **W** (Warehouse) untuk menghindari konflik dengan Debugger (DAP).*

## 📝 Query Editor
Gunakan keymap ini saat berada di dalam buffer editor query:
| Keymap | Mode | Deskripsi |
| --- | --- | --- |
| `BB` | `n` | **Run File**: Eksekusi seluruh isi file query |
| `BB` | `v` | **Run Selection**: Eksekusi hanya bagian teks yang dipilih |

## 📂 Drawer (Sidebar Database)
Navigasi di sidebar kiri (daftar koneksi & tabel):
| Keymap | Mode | Deskripsi |
| --- | --- | --- |
| `<CR>` / `o` / `l` | `n` | Pilih/Buka item (Expand koneksi/tabel) |
| `cw` | `n` | Rename item |
| `dd` | `n` | Delete item |
| `<C-r>` | `n` | Refresh daftar koneksi |

## 📊 Result View (Tampilan Hasil)
Navigasi di jendela hasil query:
| Keymap | Mode | Deskripsi |
| --- | --- | --- |
| `<C-n>` / `<C-p>` | `n` | Halaman Berikutnya / Sebelumnya |
| `yaj` | `n` | Yank (Copy) baris saat ini sebagai **JSON** |
| `yac` | `n` | Yank (Copy) baris saat ini sebagai **CSV** |

---
*Lokasi Koneksi: Koneksi kamu disimpan di `~/.local/share/nvim/dbee/connections.json`*
