# Loaded for login shells (before .zshrc)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Node (current default via nvm)
[ -d "$HOME/.nvm/versions/node/v24.12.0/bin" ] && \
  export PATH="$HOME/.nvm/versions/node/v24.12.0/bin:$PATH"

# Solana
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# JetBrains Toolbox scripts
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
