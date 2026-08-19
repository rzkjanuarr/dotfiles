#!/bin/bash

# Script untuk switch PHP version dengan Valet
# Author: Auto-generated

echo "========================================="
echo "   PHP Version Switcher untuk Valet"
echo "========================================="
echo ""

# Tampilkan PHP versi yang sedang aktif
echo "📌 PHP Versi Saat Ini:"
php -v 2>/dev/null | head -n 1 || echo "   ❌ PHP tidak ditemukan"
echo ""

# Cari semua PHP yang terinstall via Homebrew
echo "🔍 Mencari PHP yang terinstall..."
echo ""

# Array untuk menyimpan versi PHP
php_versions=()

# Cek PHP tanpa versi (latest)
if brew list --formula | grep -q "^php$"; then
    php_versions+=("php")
fi

# Cek PHP dengan versi spesifik (php@7.4, php@8.0, dll)
for version in $(brew list --formula | grep "^php@" | sort -V); do
    php_versions+=("$version")
done

# Jika tidak ada PHP terinstall
if [ ${#php_versions[@]} -eq 0 ]; then
    echo "❌ Tidak ada PHP yang terinstall via Homebrew!"
    echo "   Install PHP terlebih dahulu dengan: brew install php@8.2"
    exit 1
fi

# Tampilkan daftar PHP
echo "📋 Daftar PHP yang tersedia:"
echo ""
for i in "${!php_versions[@]}"; do
    num=$((i + 1))
    version="${php_versions[$i]}"

    # Cek apakah ini versi yang sedang aktif
    current_php=$(php -v 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
    version_number=$(echo "$version" | grep -oE '[0-9]+\.[0-9]+')

    if [[ "$current_php" == "$version_number"* ]]; then
        echo "  [$num] $version ✅ (aktif)"
    else
        echo "  [$num] $version"
    fi
done

# Tambahkan opsi exit
exit_num=$((${#php_versions[@]} + 1))
echo "  [$exit_num] Exit"

echo ""
echo "========================================="

# Input pilihan user
read -p "Pilih nomor (1-$exit_num): " choice

# Validasi input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $exit_num ]; then
    echo ""
    echo "❌ Pilihan tidak valid! Harus antara 1-$exit_num"
    exit 1
fi

# Cek jika user pilih exit
if [ "$choice" -eq $exit_num ]; then
    echo ""
    echo "👋 Keluar dari PHP Switcher. Bye!"
    echo ""
    exit 0
fi

# Ambil versi yang dipilih
selected_index=$((choice - 1))
selected_php="${php_versions[$selected_index]}"

echo ""
echo "========================================="
echo "🔄 Switching ke $selected_php..."
echo "========================================="
echo ""

# Unlink semua PHP yang ada
echo "1️⃣  Unlink PHP yang sedang aktif..."
for version in "${php_versions[@]}"; do
    brew unlink "$version" 2>/dev/null
done

echo "2️⃣  Link $selected_php..."
brew link "$selected_php" --force --overwrite

echo "3️⃣  Restart Valet..."
valet restart

echo ""
echo "========================================="
echo "✅ Berhasil switch ke $selected_php"
echo "========================================="
echo ""

# Tampilkan versi PHP yang aktif
php -v | head -n 1

echo ""
