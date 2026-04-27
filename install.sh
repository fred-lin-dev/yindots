#!/bin/sh
# ══════════════════════════════════════════════════════════════════════════════
#   install.sh — Symlinks + config post-déploiement
#   Appelé automatiquement par installer.sh après le déploiement.
#   Peut aussi être relancé manuellement (update-conf).
# ══════════════════════════════════════════════════════════════════════════════

set -e

AFS="$HOME/afs"
CONFS="$AFS/.confs"
CFG="$CONFS/Config"
WALLPAPERS="$CONFS/wallpapers"
REPO_WALLPAPER="https://github.com/fred-lin-dev/yinpi-wallpaper.git"

GREEN=$(printf '\033[0;32m')
BLUE=$(printf '\033[0;34m')
RED=$(printf '\033[0;31m')
YELLOW=$(printf '\033[0;33m')
NC=$(printf '\033[0m')

step() { printf "${BLUE}::${NC} %-42s" "$1"; }
ok()   { printf "[${GREEN}OK${NC}]\n"; }
warn() { printf "[${YELLOW}SKIP${NC}] $1\n"; }
fail() { printf "[${RED}KO${NC}]\n"; }

# ── Dotfiles → $HOME ─────────────────────────────────────────────────────────
step "Symlinks dotfiles..."
mkdir -p "$HOME/.emacs.d"
ln -sf "$CFG/.bashrc"       "$HOME/.bashrc"
ln -sf "$CFG/.bash_aliases" "$HOME/.bash_aliases"
ln -sf "$CFG/.bash_profile" "$HOME/.bash_profile"
ln -sf "$CFG/.bash_logout"  "$HOME/.bash_logout"
ln -sf "$CFG/.gitconfig"    "$HOME/.gitconfig"
ln -sf "$CFG/.vimrc"        "$HOME/.vimrc"
ln -sf "$CFG/.xprofile"     "$HOME/.xprofile"
ln -sf "$CFG/gdbinit"       "$HOME/.gdbinit"
ln -sf "$CFG/emacs/init.el" "$HOME/.emacs.d/init.el"
ok

# ── App configs → ~/.config ───────────────────────────────────────────────────
step "Symlinks ~/.config/..."
mkdir -p "$HOME/.config"
for app in alacritty i3 dunst rofi picom polybar matugen qt5ct qt6ct gtk-3.0 gtk-4.0 clang-format starship.toml; do
    src="$CFG/config/$app"
    dst="$HOME/.config/$app"
    [ -e "$src" ] || continue
    rm -rf "$dst"
    ln -sf "$src" "$dst"
done
ok

# ── Optimot ───────────────────────────────────────────────────────────────────
step "Optimot (.XCompose)..."
ln -sf "$CFG/Optimot/.XCompose" "$HOME/.XCompose"
ok

# ── Wallpapers ────────────────────────────────────────────────────────────────
step "Wallpapers..."
if [ ! -d "$WALLPAPERS" ]; then
    if git clone "$REPO_WALLPAPER" "$WALLPAPERS" > /dev/null 2>&1; then
        rm -rf "$WALLPAPERS/.git"
        ok
    else
        warn "(SSH non configuré — lance 'git clone $REPO_WALLPAPER $WALLPAPERS' manuellement)"
    fi
else
    ok
fi

# ── Wallpaper par défaut ──────────────────────────────────────────────────────
step "Wallpaper par défaut..."
if command -v feh > /dev/null 2>&1 && [ -f "$WALLPAPERS/default.jpg" ]; then
    feh --bg-fill "$WALLPAPERS/default.jpg" && cp "$HOME/.fehbg" "$CONFS/" 2>/dev/null
    ok
else
    printf "[SKIP]\n"
fi

# ── Clang-format symlinks courants ───────────────────────────────────────────
step "Clang-format symlinks..."
CLANG="$CFG/config/clang-format"
ln -sf "clang-format-c-epita-ing1-2025-2026"   "$CLANG/clang-format-c-current"   2>/dev/null || true
ln -sf "clang-format-cxx-epita-ing1-2025-2026" "$CLANG/clang-format-cxx-current" 2>/dev/null || true
ok

printf "\n${GREEN}Installation terminée !${GREEN} Reconnecte-toi (ou recharge i3 : Mod+Shift+r).${NC}\n\n"
