# ===================================================
# functions.zsh
# ===================================================

# ─── [JAVA] switch version ─────────────────────────
jv() {
  export JAVA_HOME=$(/usr/libexec/java_home -v "$1")
  export PATH="$JAVA_HOME/bin:$PATH"
  java -version
}

# ─── [PHP] switch version ──────────────────────────
pv() {
  brew unlink php 2>/dev/null
  brew unlink "php@$1" 2>/dev/null
  brew link --overwrite --force "php@$1"
  export PATH="/opt/homebrew/opt/php@$1/bin:$PATH"
  php -v | head -1
}

# ─── Buat folder + langsung masuk ──────────────────
mcd() { mkdir -p "$1" && cd "$1" }

# ─── Cari file by name ─────────────────────────────
ff() { find . -name "*$1*" 2>/dev/null }

# ─── Grep rekursif ─────────────────────────────────
fgg() { grep -rn "$1" . }

# ─── Extract berbagai format archive ───────────────
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.tar.xz)  tar xJf "$1" ;;
      *.zip)     unzip "$1"   ;;
      *.gz)      gunzip "$1"  ;;
      *.rar)     unrar x "$1" ;;
      *.7z)      7z x "$1"    ;;
      *)         echo "Format tidak dikenali: $1" ;;
    esac
  else
    echo "File tidak ditemukan: $1"
  fi
}

# ─── Quick HTTP server ─────────────────────────────
serve() { python3 -m http.server "${1:-8080}" }

# ─── [HELP] Cheatsheet semua alias per section ─────
cs() {
  echo "\n🗂  \033[1;33m[NAV] Navigation\033[0m"
  echo "  ..  ...  ....  → cd ke atas | -  → dir sebelumnya"
  echo "\n📁  \033[1;33m[LS]\033[0m  ll / la / lt"
  echo "\n🍞  \033[1;33m[BUN]\033[0m  bi / ba / bd"
  echo "\n🐦  \033[1;33m[FVM]\033[0m  fl fld flb flpub flclean fldart fvml fvmu"
  echo "\n🤙  \033[1;33m[ANDROID]\033[0m  mesin_1 / mesin_2 / emulator -list-avds"
  echo "\n🐍  \033[1;33m[PY]\033[0m  py / pip / venv / activate"
  echo "\n🦀  \033[1;33m[RS]\033[0m  cr cb ct ccheck cfmt cclippy"
  echo "\n📝  \033[1;33m[VIM]\033[0m  v / vi / vim → nvim"
  echo "\n☕  \033[1;33m[JAVA]\033[0m  jv <ver> / jv11 / jv17 / jvlist"
  echo "\n🐘  \033[1;33m[PHP]\033[0m  pv <ver> / pv81..85 / pvlist"
  echo "\n⚙️   \033[1;33m[SYS]\033[0m  c hosts ip pubip flushdns ports sizeof cpwd brewup cleanup"
  echo "\n🔧  \033[1;33m[ZSH]\033[0m  br (reload) / brr (edit) / dot (cd dotfiles)"
  echo "\n🔨  \033[1;33m[FN]\033[0m  mcd ff fgg extract serve cs"
  echo "\n🔨  \033[1;33m[CUSTOM]\033[0m  gpus switch_php mysql_manager pull_video clean_video"
  echo ""
}
