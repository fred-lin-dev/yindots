#!/usr/bin/env bash

OPTIMOT_DIR="$(cd "$(dirname "$0")" && pwd)"

ln -sf "$OPTIMOT_DIR/.XCompose" "$HOME/.XCompose"

# Trouver xkbcomp (disponible system-wide sur NixOS avec X11)
XKBCOMP=$(command -v xkbcomp 2>/dev/null)
if [ -z "$XKBCOMP" ]; then
    echo "load_keyboard.sh: xkbcomp introuvable" >&2
    exit 1
fi

# Trouver la config XKB du système (NixOS, FHS standard)
XKB_ROOT=""
for p in \
    /run/current-system/sw/share/X11/xkb \
    /usr/share/X11/xkb \
    /etc/X11/xkb; do
    [ -d "$p" ] && XKB_ROOT="$p" && break
done

if [ -n "$XKB_ROOT" ]; then
    "$XKBCOMP" -I"$XKB_ROOT" -w 0 "$OPTIMOT_DIR/Optimot.xkb" "$DISPLAY"
else
    "$XKBCOMP" -w 0 "$OPTIMOT_DIR/Optimot.xkb" "$DISPLAY"
fi
