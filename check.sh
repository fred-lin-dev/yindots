#!/bin/sh
# Diagnostique l'état de l'installation yindots

AFS="$HOME/afs"
CONFS="$AFS/.confs"
CFG="$CONFS/Config"

GREEN=$(printf '\033[0;32m')
RED=$(printf '\033[0;31m')
YELLOW=$(printf '\033[0;33m')
NC=$(printf '\033[0m')

ok()   { printf "  ${GREEN}✓${NC} %s\n" "$1"; }
warn() { printf "  ${YELLOW}⚠${NC} %s\n" "$1"; }
fail() { printf "  ${RED}✗${NC} %s\n" "$1"; }

echo "=== yindots check ==="
echo ""

echo "[Symlinks dotfiles]"
for f in .bashrc .bash_aliases .gitconfig .vimrc .xprofile .gdbinit; do
    if [ -L "$HOME/$f" ]; then ok "$f → $(readlink $HOME/$f)"
    else fail "$f (absent ou non-symlink)"; fi
done
[ -L "$HOME/.emacs.d/init.el" ] && ok ".emacs.d/init.el" || fail ".emacs.d/init.el"
echo ""

echo "[Configs ~/.config/]"
for app in alacritty i3 dunst rofi picom polybar matugen qt5ct qt6ct; do
    if [ -L "$HOME/.config/$app" ]; then ok "$app"
    else fail "$app"; fi
done
echo ""

echo "[Optimot]"
[ -L "$HOME/.XCompose" ] && ok ".XCompose" || fail ".XCompose"
command -v xkbcomp > /dev/null 2>&1 && ok "xkbcomp disponible" || warn "xkbcomp absent"
echo ""

echo "[Nix packages]"
for pkg in bat fzf fd zoxide starship alacritty matugen autotiling picom polybar feh; do
    if command -v "$pkg" > /dev/null 2>&1; then ok "$pkg"
    else warn "$pkg absent (sera installé au 1er démarrage i3)"; fi
done
echo ""

echo "[Wallpapers]"
[ -d "$CONFS/wallpapers" ] && ok "wallpapers/ présent" || warn "wallpapers/ absent (DL au 1er install)"
echo ""

echo "[Version]"
VER_LOCAL="$(cat $CONFS/version 2>/dev/null || echo '?')"
VER_REPO="$(curl -Ls https://raw.githubusercontent.com/yinpi21/yindots/main/version 2>/dev/null || echo '?')"
echo "  Installée : $VER_LOCAL | Repo : $VER_REPO"
[ "$VER_LOCAL" = "$VER_REPO" ] && ok "À jour" || warn "Mise à jour disponible (update-conf)"
echo ""
