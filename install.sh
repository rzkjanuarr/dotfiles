#!/usr/bin/env bash
# ===================================================
# install.sh — symlink dotfiles ke lokasi asli
# Idempotent: aman dijalankan berulang. Auto-backup file lama.
# ===================================================
set -e

DOTFILES="$HOME/dotfiles"
BACKUP="$DOTFILES/backup/pre-install-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"

link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    rm "$dst"                       # ganti symlink lama
  elif [ -e "$dst" ]; then
    mv "$dst" "$BACKUP/"            # backup file/dir asli
    echo "  backup: $dst -> $BACKUP/"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "  linked: $dst -> $src"
}

echo "==> zsh"
link "$DOTFILES/zsh/.zshrc"    "$HOME/.zshrc"
link "$DOTFILES/zsh/.zshenv"   "$HOME/.zshenv"
link "$DOTFILES/zsh/.zprofile" "$HOME/.zprofile"

echo "==> ghostty"
link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

echo "==> nvim"
link "$DOTFILES/nvim" "$HOME/.config/nvim"

echo "==> prettier (global config)"
link "$DOTFILES/.prettierrc" "$HOME/.prettierrc"

echo "==> starship (via STARSHIP_CONFIG di .zshrc, tidak perlu symlink)"

echo "==> scripts (symlink ke ~/ agar path lama tetap jalan)"
for s in gpus switch_php mysql pull_video clean_video; do
  link "$DOTFILES/scripts/$s.sh" "$HOME/$s.sh"
done

echo "==> secrets"
if [ ! -f "$HOME/.zsh_secrets" ]; then
  cp "$DOTFILES/zsh/.zsh_secrets.example" "$HOME/.zsh_secrets"
  echo "  created ~/.zsh_secrets dari template — ISI token asli lo!"
else
  echo "  ~/.zsh_secrets sudah ada, dilewati."
fi

echo ""
echo "✅ Selesai. Jalankan: exec zsh   (atau buka Ghostty baru)"
