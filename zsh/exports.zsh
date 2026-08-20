# ===================================================
# exports.zsh - PATH, environment, version managers
# ===================================================

# ─── Homebrew ──────────────────────────────────────
eval "$(/opt/homebrew/bin/brew shellenv)"

# ─── PATH ──────────────────────────────────────────
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"        # Rust / Cargo
export PATH="/usr/local/share/dotnet:$PATH" # .NET
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="/opt/homebrew/opt/python3/bin:$PATH"

# ─── Android SDK ───────────────────────────────────
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/emulator:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# ─── FVM (Flutter) ─────────────────────────────────
export PATH="$HOME/fvm/default/bin:$PATH"

# ─── NVM ───────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Auto-switch node version jika ada .nvmrc
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    local nvmrc_ver=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_ver" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_ver" != "$(nvm version)" ]; then
      nvm use
    fi
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# ─── Java (default v17) ────────────────────────────
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# ─── PHP (default: latest) ─────────────────────────
export PATH="/opt/homebrew/opt/php/bin:$PATH"

# ─── Bun ───────────────────────────────────────────
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ─── Solana / local bin / LM Studio ────────────────
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"

# ─── Claude Code (custom endpoint) ─────────────────
export ANTHROPIC_BASE_URL="https://api.aihack.web.id/v1"
export ANTHROPIC_API_KEY="sk-4d759057d9d093f2"
export ANTHROPIC_MODEL="claude-opus-4.6"

# ─── Editor ────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"

# ─── History ───────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ─── Tmux ──────────────────────────────────────────
export TMUX_CONF="$HOME/.config/tmux/tmux.conf"
