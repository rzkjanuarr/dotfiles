#!/bin/bash

# ========== REUSABLE FUNCTIONS ==========

function select_commit_type() {
    echo "=================================================="
    echo "Tentukan tipe commit message Anda !"
    echo "1. FEAT: Feature baru"
    echo "2. WIP: Work in progress"
    echo "3. FIX: Bug fix"
    echo "4. BUILD: Build system"
    echo "5. CHORE: Maintenance"
    echo "6. PERF: Performance"
    echo "7. DOCS: Documentation"
    echo "8. REFACTOR: Refactoring"
    echo "9. REVERT: Revert changes"
    echo "10. TEST: Testing"
    echo "=================================================="
    echo "Contoh output: FEAT[rizki]: feat login page"
    echo "=================================================="
    read -p "Silahkan pilih 1 - 10 : " commit_type
    
    case $commit_type in
        1) type="FEAT" ;;
        2) type="WIP" ;;
        3) type="FIX" ;;
        4) type="BUILD" ;;
        5) type="CHORE" ;;
        6) type="PERF" ;;
        7) type="DOCS" ;;
        8) type="REFACTOR" ;;
        9) type="REVERT" ;;
        10) type="TEST" ;;
        *) echo "Tipe commit yang Anda maksud tidak ada!" ; exit 1 ;;
    esac
    
    read -p "Masukan nama Anda : " name
    read -p "Masukan deskripsi : " desc
    
    message="$type[$name]: $desc"
    echo "=================================================="
    echo "Hasil commit Anda : $message"
    echo "=================================================="
}

function select_add_mode() {
    echo "Pilih cara menambahkan file:"
    echo "1. Pilih file manual (satu per satu)"
    echo "2. Add semua file (git add .)"
    echo "3. Add semua KECUALI file tertentu"
    echo "4. Add interaktif (git add -p)"
    read -p "Pilihan (1-4): " add_mode
    
    case $add_mode in
        1)
            echo "File yang tersedia:"
            git status -s
            echo ""
            echo "Masukkan nama file (pisahkan dengan spasi jika lebih dari satu):"
            read -p "> " files
            git add $files
            ;;
        2)
            git add .
            ;;
        3)
            echo "=================================================="
            echo "File yang tersedia:"
            echo "=================================================="
            git status -s
            echo ""
            echo "Masukkan file yang TIDAK ingin di-add (pisahkan dengan spasi):"
            read -p "> " excluded_files
            
            # Add semua file dulu
            git add .
            
            # Reset file yang dikecualikan
            if [ -n "$excluded_files" ]; then
                git reset -- $excluded_files
            fi
            
            # Tampilkan hasil
            echo ""
            echo "=================================================="
            echo "✅ HASIL STAGING:"
            echo "=================================================="
            echo "File yang DI-STAGE (akan di-commit):"
            git diff --cached --name-status
            echo ""
            echo "❌ File yang DIKECUALIKAN (tidak di-stage):"
            if [ -n "$excluded_files" ]; then
                echo "$excluded_files" | tr ' ' '\n' | sed 's/^/   - /'
            else
                echo "   (tidak ada)"
            fi
            echo "=================================================="
            ;;
        4)
            git add -p
            ;;
        *)
            echo "Pilihan tidak valid, menggunakan git add ."
            git add .
            ;;
    esac
}

# ========== MENU FUNCTIONS ==========

function init_commit() {
    echo "=================================================="
    read -p "Silahkan masukan link github Anda : " github_link
    if [ -z "$github_link" ]; then
        echo "Anda harus mengisi repositori Github!"
        exit 1
    fi
    echo "=================================================="
    echo "Initial commit pada link : $github_link"
    echo "=================================================="
    
    rm -rf .git 2>/dev/null
    git init
    git remote remove origin 2>/dev/null
    git remote add origin "$github_link"
    git add .
    git commit -m "🎉 Initial commit"
    git push --set-upstream origin master --force
    
    echo "That's it. Silahkan kembali ke workspace Anda!"
}

function commit_push() {
    echo "=================================================="
    echo "File yang telah Anda kerjakan :"
    echo "=================================================="
    git status
    
    select_commit_type
    select_add_mode
    
    git commit -m "$message"
    git push
    echo "That's it. Silahkan kembali ke workspace Anda!"
}

function create_branch() {
    echo "=================================================="
    echo "Fetching latest data from origin..."
    echo "=================================================="
    git fetch origin
    echo "=================================================="
    echo "Menampilkan branch yang ada saat ini :"
    echo "=================================================="
    git branch | cat
    echo "=================================================="
    read -p "Masukan nama branch baru : " new_branch
    git checkout -b "$new_branch"
    echo "=================================================="
    echo "Saat ini Anda di branch :"
    git branch --show-current
    echo "=================================================="
    echo "That's it. Silahkan kembali ke workspace Anda!"
}

function switch_branch() {
    echo "=================================================="
    echo "Fetching latest data from origin..."
    echo "=================================================="
    git fetch origin
    echo "=================================================="
    echo "Menampilkan branch yang ada saat ini :"
    echo "=================================================="
    git branch | cat
    echo "=================================================="
    read -p "Masukan nama branch tujuan : " existing_branch
    git checkout "$existing_branch"
    echo "=================================================="
    echo "Saat ini Anda di branch :"
    git branch --show-current
    echo "=================================================="
    echo "That's it. Silahkan kembali ke workspace Anda!"
}

function push_branch() {
    echo "=================================================="
    echo "File yang telah Anda kerjakan :"
    git status
    
    select_commit_type
    select_add_mode
    
    git commit -m "$message"
    echo "=================================================="
    echo "Menampilkan branch Anda saat ini :"
    git branch | cat
    echo "=================================================="
    read -p "Masukkan nama branch yang akan dipush: " branch_name
    git push origin "$branch_name"
    
    # Tanyakan apakah ingin membuat Pull Request
    echo "=================================================="
    read -p "Apakah Anda ingin membuat Pull Request? (y/n): " create_pr
    
    if [ "$create_pr" = "y" ] || [ "$create_pr" = "Y" ]; then
        # Tampilkan branch yang ada
        echo "=================================================="
        echo "Fetching latest branches from origin..."
        git fetch origin
        echo "=================================================="
        echo "Branch yang tersedia:"
        git branch -r | grep -v HEAD | sed 's/origin\///' | cat
        echo "=================================================="
        
        # Tanyakan target branch untuk PR
        read -p "Masukkan target branch untuk PR (contoh: G-Logistik): " target_branch
        
        if [ -z "$target_branch" ]; then
            echo "Target branch tidak boleh kosong!"
        else
            # Tanyakan title PR (default dari commit message)
            echo "=================================================="
            read -p "Masukkan title PR (tekan Enter untuk menggunakan commit message): " pr_title
            if [ -z "$pr_title" ]; then
                pr_title="$message"
            fi
            
            # Tanyakan deskripsi PR (opsional)
            read -p "Masukkan deskripsi PR (opsional, tekan Enter untuk skip): " pr_body
            
            # Buat Pull Request
            echo "=================================================="
            echo "Membuat Pull Request..."
            echo "  From: $branch_name"
            echo "  To: $target_branch"
            echo "  Title: $pr_title"
            echo "=================================================="
            
            if [ -z "$pr_body" ]; then
                gh pr create --base "$target_branch" --head "$branch_name" --title "$pr_title"
            else
                gh pr create --base "$target_branch" --head "$branch_name" --title "$pr_title" --body "$pr_body"
            fi
            
            if [ $? -eq 0 ]; then
                echo "=================================================="
                echo "✅ Pull Request berhasil dibuat!"
                echo "=================================================="
            else
                echo "=================================================="
                echo "❌ Gagal membuat Pull Request!"
                echo "=================================================="
            fi
        fi
    fi
    
    echo "That's it. Silahkan kembali ke workspace Anda!"
}

function switch_main() {
    echo "=================================================="
    echo "Mendeteksi branch utama (main/master)..."
    if git show-ref --verify --quiet refs/heads/main; then
        main_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    else
        echo "Branch utama tidak ditemukan (main/master)."
        exit 1
    fi
    git checkout "$main_branch"
    git fetch
    git pull
    echo "=================================================="
    echo "Saat ini Anda di branch :"
    git branch --show-current
    echo "=================================================="
    echo "That's it. Silahkan kembali ke workspace Anda!"
}

function pull_branch() {
    echo "=================================================="
    echo "Fetching latest data from origin..."
    echo "=================================================="
    git fetch origin
    echo "=================================================="
    echo "Menampilkan branch yang ada saat ini :"
    echo "=================================================="
    git branch | cat
    echo "=================================================="
    echo "Saat ini Anda di branch :"
    current_branch=$(git branch --show-current)
    echo "$current_branch"
    echo "=================================================="
    read -p "Pull dari branch mana? (tekan Enter untuk pull dari branch saat ini): " branch_name
    
    # Jika tidak diisi, gunakan branch saat ini
    if [ -z "$branch_name" ]; then
        branch_name="$current_branch"
    fi
    
    echo "=================================================="
    echo "Pulling dari origin/$branch_name..."
    echo "=================================================="
    git pull origin "$branch_name"
    echo "=================================================="
    echo "That's it. Silahkan kembali ke workspace Anda!"
}

# ========== MAIN MENU ==========

echo "=================================================="
echo " Pilih menu yang kamu butuhkan :"
echo "=================================================="
echo " 1. Initial commit"
echo " 2. Commit and push (All in one)"
echo " 3. New branch"
echo " 4. Switch branch"
echo " 5. Push branch [NEW]"
echo " 6. Switch to main branch (wajib sudah PR dan merge)"
echo " 7. Pull from origin branch [NEW]"
echo "=================================================="
read -p "Silahkan pilih 1 - 7 : " choice

case $choice in
    1) init_commit ;;
    2) commit_push ;;
    3) create_branch ;;
    4) switch_branch ;;
    5) push_branch ;;
    6) switch_main ;;
    7) pull_branch ;;
    *) echo "Pilihan tidak valid." ; exit 1 ;;
esac