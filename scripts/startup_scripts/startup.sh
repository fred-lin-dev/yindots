#!/bin/sh

. "$HOME/afs/.confs/scripts/globals.sh"

IDA=42
IDB=43

dunstify -r "$IDA" -t 0 "=== Yindots Startup ==="

# ── Wallpaper ─────────────────────────────────────────────────────────────────
if [ -f "$SCRIPTS/wallpaper_scripts/safe_change_wallpaper.sh" ]; then
    sh "$SCRIPTS/wallpaper_scripts/safe_change_wallpaper.sh" > /dev/null 2>&1
fi

# ── Paquets Nix (si bat absent = 1er démarrage) ───────────────────────────────
if [ ! -x "$HOME/.nix-profile/bin/bat" ] || [ ! -x "$HOME/.nix-profile/bin/greenclip" ] || [ ! -x "$HOME/.nix-profile/bin/xkbcomp" ]; then
    dunstify -r "$IDB" -t 0 "Installation des paquets supplémentaires..."
    PACKAGES="
    nixpkgs#autotiling
    nixpkgs#papirus-icon-theme
    nixpkgs#bat
    nixpkgs#adw-gtk3
    nixpkgs#pqiv
    nixpkgs#emacs
    nixpkgs#clang-tools
    nixpkgs#ripgrep
    nixpkgs#flameshot
    nixpkgs#fzf
    nixpkgs#fd
    nixpkgs#zoxide
    nixpkgs#starship
    nixpkgs#matugen
    nixpkgs#rofi
    nixpkgs#picom
    nixpkgs#polybar
    nixpkgs#feh
    nixpkgs#bc
    nixpkgs#playerctl
    nixpkgs#xorg.xkbcomp
    nixpkgs#greenclip
    nixpkgs#nerd-fonts.jetbrains-mono
    "
    if nix profile install $PACKAGES --impure > /dev/null 2>&1; then
        dunstify -r "$IDB" -t 5000 "Paquets installés [OK]"
    else
        dunstify -r "$IDB" -u critical "Installation paquets [FAIL]"
    fi
fi

# ── Pywalfox ──────────────────────────────────────────────────────────────────
if [ -f "$CONFIG/matugen/pywalfox.json" ]; then
    mkdir -p "$HOME/.cache/wal"
    ln -sf "$CONFIG/matugen/pywalfox.json" "$HOME/.cache/wal/colors.json"

    dunstify -r "$IDB" -t 0 "Configuration Pywalfox..."
    if command -v pywalfox > /dev/null 2>&1 && pywalfox install > /dev/null 2>&1; then
        dunstify -r "$IDB" -t 3000 "Pywalfox [OK]"
    else
        dunstify -u critical "Pywalfox [FAIL]"
    fi
fi

# ── Reload i3 ─────────────────────────────────────────────────────────────────
dunstify -r "$IDB" -t 0 "Rechargement i3..."
if i3-msg restart > /dev/null 2>&1; then
    dunstify -r "$IDB" -t 3000 "i3 rechargé [OK]"
else
    dunstify -r "$IDB" -t 3000 "i3 restart [SKIP]"
fi

# ── Scripts de démarrage supplémentaires ─────────────────────────────────────
LOG_FILE="/tmp/yindots_startup.log"
echo "===== STARTUP LOG =====" > "$LOG_FILE"

if [ -d "$SCRIPTS/startup_scripts" ]; then
    for f in "$SCRIPTS/startup_scripts"/*; do
        [ -f "$f" ] || continue
        fname="${f##*/}"
        [ "$fname" = "startup.sh" ] || [ "$fname" = "check_update.sh" ] && continue
        chmod +x "$f"
        echo "===== $fname =====" >> "$LOG_FILE"
        dunstify -r "$IDB" -t 0 "Exécution : $fname"
        "$f" >> "$LOG_FILE" 2>&1 || dunstify -u critical "Erreur : $fname" "Voir $LOG_FILE"
    done

    [ -f "$SCRIPTS/startup_scripts/check_update.sh" ] && \
        sh "$SCRIPTS/startup_scripts/check_update.sh" > /dev/null 2>&1 &
fi

dunstify -r "$IDB" -t 5000 "Prêt !"
sleep 5
dunstify -C "$IDA"
