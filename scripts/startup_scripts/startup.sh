#!/bin/sh
# Script de démarrage i3 — EPITA NixOS
# Lancé par exec --no-startup-id dans la config i3

source "$HOME/afs/.confs/scripts/globals.sh"

# Ouvre Firefox et AFS en arrière-plan
nohup firefox > /dev/null 2>&1 &
nohup "$SCRIPTS/system/open_afs.sh" &

IDA=42
IDB=43

dunstify -r "$IDA" -t 0 "=== Startup EPITA ==="

# ── Wallpaper ──────────────────────────────────────────────────────────────────
if [ -f "$SCRIPTS/wallpaper_scripts/safe_change_wallpaper.sh" ]; then
    sh "$SCRIPTS/wallpaper_scripts/safe_change_wallpaper.sh" > /dev/null 2>&1
fi

# ── Installation des packages nix si absents ───────────────────────────────────
if [ ! -x "$HOME/.nix-profile/bin/bat" ]; then
    dunstify -r "$IDB" -t 0 "Installation des packages..."

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
    nixpkgs#matugen
    nixpkgs#starship
    "

    if nix profile install $PACKAGES --impure > /dev/null 2>&1; then
        dunstify -r "$IDB" -t 5000 "Packages installés [OK]"
    else
        dunstify -r "$IDB" -u critical "Packages installation [FAIL]"
    fi
fi

# ── Pywalfox (Firefox theming via matugen) ─────────────────────────────────────
if [ -f "$CONFS/config/matugen/pywalfox.json" ]; then
    mkdir -p "$HOME/.cache/wal"
    ln -sf "$CONFS/config/matugen/pywalfox.json" "$HOME/.cache/wal/colors.json"

    if command -v pywalfox > /dev/null 2>&1; then
        pywalfox install > /dev/null 2>&1
    fi
fi

# ── Reload i3 ────────────────────────────────────────────────────────────────
dunstify -r "$IDB" -t 0 "Rechargement i3..."
if i3-msg restart > /dev/null 2>&1; then
    dunstify -r "$IDB" -t 3000 "Rechargement i3 [OK]"
else
    dunstify -r "$IDB" -t 3000 "Rechargement i3 [SKIP]"
fi

# ── Exécution des autres scripts de démarrage ─────────────────────────────────
LOG_FILE="/tmp/startup_scripts.log"
echo "===== STARTUP LOG =====" > "$LOG_FILE"

if [ -d "$SCRIPTS/startup_scripts" ]; then
    for f in "$SCRIPTS/startup_scripts"/*; do
        [ -f "$f" ] || continue
        fname="${f##*/}"

        if [ "$fname" != "startup.sh" ] && [ "$fname" != "aklogger.sh" ] && [ "$fname" != "check_update.sh" ]; then
            chmod +x "$f"
            echo "===== LOG $fname =====" >> "$LOG_FILE"
            dunstify -r "$IDB" -t 0 "Exécution : $fname"
            if ! "$f" >> "$LOG_FILE" 2>&1; then
                dunstify -u critical "Erreur : $fname" "Voir $LOG_FILE"
            fi
        fi
    done

    [ -f "$SCRIPTS/startup_scripts/aklogger.sh" ]     && sh "$SCRIPTS/startup_scripts/aklogger.sh"     > /dev/null 2>&1 &
    [ -f "$SCRIPTS/startup_scripts/check_update.sh" ] && sh "$SCRIPTS/startup_scripts/check_update.sh" > /dev/null 2>&1 &
fi

dunstify -r "$IDB" -t 5000 "Tout est prêt !"
sleep 5
dunstify -C "$IDA"
