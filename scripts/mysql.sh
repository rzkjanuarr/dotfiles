#!/bin/bash

# Script untuk manage MySQL
# Author: Auto-generated

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# MySQL credentials
MYSQL_USER="root"
MYSQL_PASS="pwdpwd8"

clear

echo "========================================="
echo "       MySQL Manager untuk Mac"
echo "========================================="
echo ""

# Cek status MySQL
echo "📊 Status MySQL Saat Ini:"
if brew services list | grep -q "mysql.*started"; then
    echo -e "${GREEN}✅ MySQL sedang berjalan${NC}"
    mysql_version=$(mysql -u $MYSQL_USER -p$MYSQL_PASS -e "SELECT VERSION();" 2>/dev/null | tail -n 1)
    if [ ! -z "$mysql_version" ]; then
        echo "   Version: $mysql_version"
    fi
else
    echo -e "${RED}❌ MySQL tidak berjalan${NC}"
fi

echo ""
echo "========================================="
echo "           Menu Pilihan"
echo "========================================="
echo ""
echo "  [1] Start MySQL"
echo "  [2] Stop MySQL"
echo "  [3] Restart MySQL"
echo "  [4] Check Status MySQL"
echo "  [5] Login ke MySQL"
echo "  [6] Show Databases"
echo "  [7] Create Database"
echo "  [8] Exit"
echo ""
echo "========================================="

# Input pilihan user
read -p "Pilih nomor (1-8): " choice

echo ""

case $choice in
    1)
        echo "🚀 Starting MySQL..."
        brew services start mysql
        echo ""
        echo -e "${GREEN}✅ MySQL berhasil distart!${NC}"
        ;;
    2)
        echo "🛑 Stopping MySQL..."
        brew services stop mysql
        echo ""
        echo -e "${YELLOW}⚠️  MySQL berhasil distop!${NC}"
        ;;
    3)
        echo "🔄 Restarting MySQL..."
        brew services restart mysql
        echo ""
        echo -e "${GREEN}✅ MySQL berhasil direstart!${NC}"
        ;;
    4)
        echo "📊 Checking MySQL Status..."
        echo ""
        brew services list | grep mysql
        echo ""
        if brew services list | grep -q "mysql.*started"; then
            echo -e "${GREEN}✅ MySQL sedang berjalan${NC}"
            echo ""
            echo "Detail koneksi:"
            mysql -u $MYSQL_USER -p$MYSQL_PASS -e "SELECT USER() as CurrentUser, VERSION() as Version, DATABASE() as CurrentDB;" 2>/dev/null
        else
            echo -e "${RED}❌ MySQL tidak berjalan${NC}"
        fi
        ;;
    5)
        echo "🔐 Login ke MySQL sebagai root..."
        echo ""
        echo -e "${BLUE}Tip: Ketik 'exit' atau 'quit' untuk keluar dari MySQL${NC}"
        echo ""
        sleep 1
        mysql -u $MYSQL_USER -p$MYSQL_PASS
        ;;
    6)
        echo "📋 Daftar Database:"
        echo ""
        if brew services list | grep -q "mysql.*started"; then
            mysql -u $MYSQL_USER -p$MYSQL_PASS -e "SHOW DATABASES;" 2>/dev/null
        else
            echo -e "${RED}❌ MySQL tidak berjalan! Start MySQL terlebih dahulu.${NC}"
        fi
        ;;
    7)
        echo "➕ Create Database Baru"
        echo ""
        read -p "Masukkan nama database: " db_name

        if [ -z "$db_name" ]; then
            echo -e "${RED}❌ Nama database tidak boleh kosong!${NC}"
            exit 1
        fi

        if brew services list | grep -q "mysql.*started"; then
            mysql -u $MYSQL_USER -p$MYSQL_PASS -e "CREATE DATABASE \`$db_name\`;" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo ""
                echo -e "${GREEN}✅ Database '$db_name' berhasil dibuat!${NC}"
                echo ""
                echo "📋 Daftar Database:"
                mysql -u $MYSQL_USER -p$MYSQL_PASS -e "SHOW DATABASES;" 2>/dev/null
            else
                echo -e "${RED}❌ Gagal membuat database! Mungkin sudah ada.${NC}"
            fi
        else
            echo -e "${RED}❌ MySQL tidak berjalan! Start MySQL terlebih dahulu.${NC}"
        fi
        ;;
    8)
        echo "👋 Keluar dari MySQL Manager. Bye!"
        echo ""
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Pilihan tidak valid! Harus antara 1-8${NC}"
        exit 1
        ;;
esac

echo ""
