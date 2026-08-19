#!/bin/bash

# Script untuk membersihkan semua video dari Android Emulator
# Author: Antigravity AI
# Date: 2025-12-18

echo "================================================"
echo "  🗑️  Hapus Semua Video dari Android Emulator"
echo "================================================"
echo ""

# Langkah 1: Tampilkan daftar video yang akan dihapus
echo "🔍 Langkah 1: Mencari video di emulator..."
echo ""
video_count=$(adb shell "ls -1 /sdcard/Movies/*.mp4 2>/dev/null | wc -l" | tr -d ' ')

if [ "$video_count" -eq 0 ]; then
    echo "✅ Tidak ada video di emulator. Folder sudah bersih!"
    exit 0
fi

echo "📹 Ditemukan $video_count video:"
echo ""
adb shell "ls -lh /sdcard/Movies/*.mp4 2>/dev/null"
echo ""
echo "================================================"
echo ""

# Langkah 2: Konfirmasi penghapusan
echo "⚠️  PERINGATAN: Semua video akan dihapus PERMANEN!"
echo ""
read -p "Apakah Anda yakin ingin menghapus SEMUA video? (ketik 'YES' untuk konfirmasi): " confirmation

if [ "$confirmation" != "YES" ]; then
    echo ""
    echo "❌ Penghapusan dibatalkan."
    exit 0
fi

# Langkah 3: Hapus semua video
echo ""
echo "🗑️  Langkah 3: Menghapus semua video..."
echo ""

adb shell "rm -f /sdcard/Movies/*.mp4"

# Cek apakah penghapusan berhasil
if [ $? -eq 0 ]; then
    echo ""
    echo "================================================"
    echo "✅ Berhasil! Semua video telah dihapus."
    echo "================================================"
    
    # Verifikasi folder kosong
    echo ""
    echo "📊 Status folder Movies:"
    remaining=$(adb shell "ls -1 /sdcard/Movies/*.mp4 2>/dev/null | wc -l" | tr -d ' ')
    if [ "$remaining" -eq 0 ]; then
        echo "✅ Folder Movies sudah bersih (0 video)"
    else
        echo "⚠️  Masih ada $remaining video tersisa"
    fi
else
    echo ""
    echo "================================================"
    echo "❌ Gagal menghapus video!"
    echo "   Pastikan emulator running dan ADB terhubung"
    echo "================================================"
    exit 1
fi
