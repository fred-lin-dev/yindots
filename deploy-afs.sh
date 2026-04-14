#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#   deploy-afs.sh — Déploie config-epita/ dans ~/AFS/.confs/ et teste
#
#   Simule exactement le comportement sur la machine EPITA :
#     - ~/afs/  (EPITA) ou ~/AFS/ (perso) joue le rôle de HOME — auto-détecté
#     - ~/afs/.confs/ = là où le repo serait cloné
#
#   Usage :
#     bash deploy-afs.sh          # sync + install + check
#     bash deploy-afs.sh sync     # sync uniquement (sans install)
#     bash deploy-afs.sh check    # check uniquement (sans resync)
#     bash deploy-afs.sh clean    # supprime ce que install.sh a créé dans ~/afs/
# ══════════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-all}"

# Auto-détection du point de montage AFS (~/afs sur EPITA, ~/AFS sur perso)
if [ -d "$HOME/afs" ]; then
    AFS_HOME="$HOME/afs"
elif [ -d "$HOME/AFS" ]; then
    AFS_HOME="$HOME/AFS"
else
    AFS_HOME="$HOME/afs"  # fallback EPITA
fi

TARGET="$AFS_HOME/.confs"

RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
NC="\033[0m"

ok()   { printf "${GREEN}  ✓${NC} %s\n" "$1"; }
info() { printf "${BLUE} ::${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}  !${NC} %s\n" "$1"; }
err()  { printf "${RED}  ✗${NC} %s\n" "$1"; exit 1; }

# ── Vérifications ─────────────────────────────────────────────────────────────
# Garde : ce script est uniquement pour tester depuis un PC perso (pas EPITA)
# Sur EPITA utilise : curl -Ls https://raw.githubusercontent.com/yinpi21/yindots/main/installer.sh | sh
if echo "$SCRIPT_DIR" | grep -q "/afs/"; then
    err "Ce script est réservé au PC perso (pas depuis AFS). Sur EPITA, utilise :\n  curl -Ls https://raw.githubusercontent.com/yinpi21/yindots/main/installer.sh | sh"
fi

[ -d "$AFS_HOME" ]  || err "Dossier AFS introuvable ($AFS_HOME). AFS monté ?"
[ -d "$SCRIPT_DIR/Config" ] || err "Config/ introuvable dans $SCRIPT_DIR"

# ── Mode clean ────────────────────────────────────────────────────────────────
if [ "$MODE" = "clean" ]; then
    info "Nettoyage de ~/AFS/ (symlinks créés par install.sh)..."

    # Symlinks ~/.config/
    for app in alacritty picom polybar rofi matugen clang-format dunst gtk-3.0 gtk-4.0 qt5ct qt6ct i3 flameshot; do
        dst="$AFS_HOME/.config/$app"
        if [ -L "$dst" ]; then
            rm "$dst"
            ok "  Supprimé $dst"
        fi
    done
    [ -L "$AFS_HOME/.config/starship.toml" ] && rm "$AFS_HOME/.config/starship.toml" && ok "  Supprimé starship.toml"

    # Dotfiles
    for f in .bashrc .bash_aliases .bash_profile .bash_logout .gitconfig .vimrc .gdbinit; do
        dst="$AFS_HOME/$f"
        if [ -L "$dst" ]; then
            rm "$dst"
            ok "  Supprimé ~AFS/$f"
        fi
    done

    [ -L "$AFS_HOME/.emacs.d/init.el" ] && rm "$AFS_HOME/.emacs.d/init.el" && ok "  Supprimé .emacs.d/init.el"

    ok "Nettoyage terminé."
    exit 0
fi

# ── Sync config-epita/ → ~/AFS/.confs/ ───────────────────────────────────────
if [ "$MODE" = "all" ] || [ "$MODE" = "sync" ]; then
    info "Sync de config-epita/ → ~/AFS/.confs/ ..."
    mkdir -p "$TARGET"

    for item in Config scripts install.sh check.sh version; do
        src="$SCRIPT_DIR/$item"
        dst="$TARGET/$item"

        if [ ! -e "$src" ]; then
            warn "  $item manquant dans config-epita/ (skip)"
            continue
        fi

        # Fichiers : supprimer explicitement avant de copier (cp -f ne remplace pas sur AFS)
        # Dossiers : cp -rf merge sans supprimer (évite de toucher .__afs* AFS)
        if [ -L "$dst" ]; then
            unlink "$dst"
        elif [ -f "$dst" ]; then
            rm -f "$dst"
        fi

        if [ -d "$src" ]; then
            cp -rf "$src/." "$dst/"
        else
            cp "$src" "$dst"
        fi
        ok "  $item → $TARGET/"
    done

    chmod +x "$TARGET/install.sh" "$TARGET/check.sh"
    find "$TARGET/scripts" -name "*.sh" -exec chmod +x {} \;
    ok "Sync terminé."
    echo ""
fi

# ── install.sh avec HOME=~/AFS ────────────────────────────────────────────────
if [ "$MODE" = "all" ]; then
    info "Lancement de install.sh (HOME=$AFS_HOME)..."
    echo ""
    HOME="$AFS_HOME" bash "$TARGET/install.sh"
    echo ""
fi

# ── check.sh avec HOME=~/AFS ─────────────────────────────────────────────────
if [ "$MODE" = "all" ] || [ "$MODE" = "check" ]; then
    info "Lancement de check.sh (HOME=$AFS_HOME)..."
    echo ""
    HOME="$AFS_HOME" bash "$TARGET/check.sh"
fi
