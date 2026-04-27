#!/bin/sh
# Supprime yindots et restaure un état minimal

AFS="$HOME/afs"
CONFS="$AFS/.confs"

echo "Suppression de yindots..."
for f in .bashrc .bash_aliases .gitconfig .vimrc .xprofile .gdbinit .XCompose; do
    [ -L "$HOME/$f" ] && unlink "$HOME/$f"
done
[ -L "$HOME/.emacs.d/init.el" ] && unlink "$HOME/.emacs.d/init.el"
for app in alacritty i3 dunst rofi picom polybar matugen qt5ct qt6ct gtk-3.0 gtk-4.0 clang-format starship.toml; do
    [ -L "$HOME/.config/$app" ] && unlink "$HOME/.config/$app"
done

echo "Yindots désinstallé. Reconnecte-toi."
