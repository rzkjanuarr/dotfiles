# dotfiles

Config terpusat untuk macOS (Apple Silicon). Satu folder, per-komponen.

## Struktur

```
~/dotfiles/
├── zsh/          .zshrc .zshenv .zprofile + exports/aliases/functions.zsh + secrets.example
├── starship/     starship.toml (Catppuccin Mocha, 2-line, powerline)
├── ghostty/      config (JetBrainsMono Nerd Font + ligatures)
├── scripts/      gpus / switch_php / mysql / pull_video / clean_video (.sh)
├── nvim/         config Neovim (~/.config/nvim di-symlink ke sini)
├── backup/       backup config lama otomatis
├── install.sh    symlink semua ke lokasi asli (idempotent)
└── .gitignore
```

## Install / re-link

```bash
cd ~/dotfiles && ./install.sh
exec zsh
```

`install.sh` membuat symlink:
- `~/.zshrc`, `~/.zshenv`, `~/.zprofile` → `zsh/`
- `~/.config/ghostty/config` → `ghostty/config`
- `~/{gpus,switch_php,mysql,pull_video,clean_video}.sh` → `scripts/`

Starship dibaca via `STARSHIP_CONFIG` di `.zshrc` (tak perlu symlink).

## Prompt — Starship

Ganti prompt lama (oh-my-zsh theme + p10k). `ZSH_THEME=""` supaya Starship yang pegang.
Edit tampilan: `nvim ~/dotfiles/starship/starship.toml`.

## Font & ligatures

Ghostty pakai **JetBrainsMono Nerd Font** (varian dengan ligatures; bukan `NL`/No-Ligatures).
`font-feature = calt/liga/dlig` mengaktifkan ligature (`==>`, `!=`, `>=`, `->` dll).

## Secrets

Token/kredensial ada di `~/.zsh_secrets` (di-source `.zshrc`, **gitignored**).
Template: `zsh/.zsh_secrets.example`.

## Git (opsional)

```bash
cd ~/dotfiles
git init && git add -A && git commit -m "init dotfiles"
# .zsh_secrets & backup/ sudah di-ignore
```
