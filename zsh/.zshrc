# ===================================================
# .zshrc - macOS (Apple Silicon)
# Modular dotfiles: ~/dotfiles/zsh/
# ===================================================

# ─── Oh My Zsh (base, tanpa theme; prompt di-handle Starship) ──
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""              # kosong: biar Starship yang ambil alih prompt
plugins=(git node npm yarn macos)
source $ZSH/oh-my-zsh.sh

# ─── Modular config ────────────────────────────────
DOTFILES="$HOME/dotfiles"
source "$DOTFILES/zsh/exports.zsh"
source "$DOTFILES/zsh/aliases.zsh"
source "$DOTFILES/zsh/functions.zsh"

# ─── Secrets (gitignored, tidak wajib ada) ─────────
[ -f "$HOME/.zsh_secrets" ] && source "$HOME/.zsh_secrets"

# ─── Atuin (history manager) ───────────────────────
eval "$(atuin init zsh)"

# ─── Tmux alias (pakai config terpusat) ────────────
alias tmux="tmux -f ~/.config/tmux/tmux.conf"

# ─── Zsh plugins (autosuggestions dulu) ────────────
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ─── Starship prompt ───────────────────────────────
export STARSHIP_CONFIG="$DOTFILES/starship/starship.toml"
eval "$(starship init zsh)"

# ─── Syntax highlighting HARUS paling akhir ────────
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
