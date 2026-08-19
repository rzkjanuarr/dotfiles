#!/bin/bash

# Script untuk pull video dari Android Emulator ke Desktop
# Author: Antigravity AI
# Date: 2025-12-18

echo "================================================"
echo "  📱 Pull Video dari Android Emulator"
echo "================================================"
echo ""

# Langkah 1: Tampilkan daftar video di emulator
echo "🔍 Langkah 1: Mencari video di emulator..."
echo ""
adb shell "ls -la /sdcard/Movies/"
echo ""
echo "================================================"
echo ""

# Langkah 2: Minta input nama file
echo "📝 Langkah 2: Masukkan nama file yang ingin di-pull"
echo ""
read -p "Nama file (contoh: screen-20251218-101337-1766027486566.mp4): " filename

# Validasi input tidak kosong
if [ -z "$filename" ]; then
    echo ""
    echo "❌ Error: Nama file tidak boleh kosong!"
    exit 1
fi

# Langkah 3: Pull file ke Desktop
echo ""
echo "⬇️  Langkah 3: Pulling file ke Desktop..."
echo ""

adb pull "/sdcard/Movies/$filename" ~/Desktop/

# Cek apakah pull berhasil
if [ $? -eq 0 ]; then
    echo ""
    echo "================================================"
    echo "✅ Berhasil! File tersimpan di:"
    echo "   ~/Desktop/$filename"
    echo "================================================"
    
    # Tampilkan info file
    echo ""
    echo "📊 Info file:"
    ls -lh ~/Desktop/"$filename"
else
    echo ""
    echo "================================================"
    echo "❌ Gagal pull file!"
    echo "   Pastikan nama file benar dan emulator running"
    echo "================================================"
    exit 1
fi
