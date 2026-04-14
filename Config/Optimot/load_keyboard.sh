#!/usr/bin/env bash

OPTIMOT_DIR="$(cd "$(dirname "$0")" && pwd)"

# XCompose — symlink vers le fichier du repo
ln -sf "$OPTIMOT_DIR/.XCompose" "$HOME/.XCompose"

# Charger le layout XKB via Nix
nix shell nixpkgs#xorg.xkbcomp nixpkgs#xkeyboard_config --command bash -c "
    export XKB_CONFIG_ROOT=\$(nix build nixpkgs#xkeyboard_config --no-link --print-out-paths)/etc/X11/xkb
    xkbcomp -I\$XKB_CONFIG_ROOT -w 0 '$OPTIMOT_DIR/Optimot.xkb' \$DISPLAY
"
