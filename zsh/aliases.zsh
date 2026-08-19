# ===================================================
# aliases.zsh
# ===================================================

# ─── [NAV] Navigation ──────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -="cd -"

# ─── [LS] List Files ───────────────────────────────
alias ll="ls -lhA"
alias la="ls -A"
alias lt="ls -lhAt"

# ─── [BUN] Bun Runtime ─────────────────────────────
alias bi="bun install"
alias ba="bun add"
alias bd="bun dev"

# ─── [FVM] Flutter Version Manager ─────────────────
alias fl="fvm flutter"
alias fld="fvm flutter run"
alias flb="fvm flutter build"
alias flpub="fvm flutter pub get"
alias flclean="fvm flutter clean"
alias fldart="fvm dart"
alias fvml="fvm list"
alias fvmu="fvm use"

# ─── [PY] Python ───────────────────────────────────
alias py="python3"
alias python="python3"
alias pip="pip3"
alias venv="python3 -m venv venv"
alias activate="source venv/bin/activate"

# ─── [RS] Rust / Cargo ─────────────────────────────
alias cr="cargo run"
alias cb="cargo build"
alias ct="cargo test"
alias ccheck="cargo check"
alias cfmt="cargo fmt"
alias cclippy="cargo clippy"

# ─── [VIM] Neovim ──────────────────────────────────
alias v="nvim"
alias vi="nvim"
alias vim="nvim"

# ─── [SYS] System & Utility ────────────────────────
alias c="clear"
alias hosts="sudo nvim /etc/hosts"
alias ip="ipconfig getifaddr en0"
alias pubip="curl -s ifconfig.me"
alias flushdns="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo '✓ DNS flushed'"
alias ports="lsof -i -P -n | grep LISTEN"
alias sizeof="du -sh"
alias cpwd="pwd | pbcopy && echo '✓ Path copied'"
alias brewup="brew update && brew upgrade && brew cleanup && echo '✓ Homebrew updated'"
alias cleanup="find . -name '.DS_Store' -delete && echo '✓ .DS_Store removed'"

# ─── [ZSH] Config (dotfiles-aware) ─────────────────
alias br="source ~/.zshrc && echo '✅ .zshrc reloaded!'"
alias brr="nvim ~/dotfiles/zsh/.zshrc"
alias dot="cd ~/dotfiles"

# ─── [AVD] Android Emulator ────────────────────────
alias mesin_1="emulator -avd andro -snapshot default_boot &"
alias mesin_2="emulator -avd andro2 -snapshot defaul_boot &"

# ─── [JAVA] Version Manager ────────────────────────
alias jv11="jv 11"
alias jv17="jv 17"
alias jvlist="/usr/libexec/java_home -V"

# ─── [PHP] Version Manager ─────────────────────────
alias pv81="pv 8.1"
alias pv82="pv 8.2"
alias pv83="pv 8.3"
alias pv84="pv 8.4"
alias pv85="pv 8.5"
alias pvlist="ls /opt/homebrew/opt/ | grep '^php'"

# ─── [CUSTOM] Scripts (dari ~/dotfiles/scripts) ────
alias gpus="~/dotfiles/scripts/gpus.sh"
alias switch_php="~/dotfiles/scripts/switch_php.sh"
alias mysql_manager="~/dotfiles/scripts/mysql.sh"
alias pull_video="~/dotfiles/scripts/pull_video.sh"
alias clean_video="~/dotfiles/scripts/clean_video.sh"
