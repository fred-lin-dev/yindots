#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#   install.sh — Config EPITA NixOS
#
#   Usage :
#     1. Clone le repo dans ~/afs/.confs/
#        git clone <repo-url> ~/afs/.confs
#     2. Lance ce script :
#        bash ~/afs/.confs/install.sh
#
#   Ce script :
#     - Crée les symlinks ~/.config/[app] → ~/afs/.confs/config/[app]
#     - Installe les dotfiles shell (~/.bashrc etc.)
#     - Configure emacs, vim, gdb, Optimot, clang-format
#     - Rend les scripts exécutables
# ══════════════════════════════════════════════════════════════════════════════

set -e

# ── Chemins ───────────────────────────────────────────────────────────────────
# Déterminé depuis la localisation du script lui-même (fonctionne partout)
CONFS="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$CONFS/Config"

# ── Couleurs ──────────────────────────────────────────────────────────────────
RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
NC="\033[0m"

ok()   { printf "${GREEN}  ✓${NC} %s\n" "$1"; }
info() { printf "${BLUE} ::${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}  !${NC} %s\n" "$1"; }
err()  { printf "${RED}  ✗${NC} %s\n" "$1"; }

# Vérifie qu'on est dans le bon dossier
if [ ! -f "$CONFS/version" ]; then
    err "version introuvable dans $CONFS"
    exit 1
fi

info "Installation de la config EPITA..."
echo ""

# ══════════════════════════════════════════════════════════════════════════════
# 1. Symlinks ~/.config/[app] → ~/afs/.confs/config/[app]
# ══════════════════════════════════════════════════════════════════════════════
info "Création des symlinks ~/.config/ ..."

mkdir -p ~/.config

# Liste des apps à symlinkrer
APPS="alacritty picom polybar rofi matugen clang-format dunst gtk-3.0 gtk-4.0 qt5ct qt6ct i3 flameshot"

for app in $APPS; do
    src="$CONFIG/config/$app"
    dst="$HOME/.config/$app"

    if [ ! -d "$src" ]; then
        warn "  Dossier source manquant : $src (skip)"
        continue
    fi

    # Supprimer l'existant si c'est déjà un symlink
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -d "$dst" ]; then
        warn "  $dst existe déjà (dossier réel). Sauvegarde → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -s "$src" "$dst"
    ok "  ~/.config/$app → $src"
done

# Starship : fichier unique ~/.config/starship.toml (pas un dossier)
STARSHIP_SRC="$CONFIG/config/starship.toml"
STARSHIP_DST="$HOME/.config/starship.toml"
if [ -f "$STARSHIP_SRC" ]; then
    [ -L "$STARSHIP_DST" ] && rm "$STARSHIP_DST"
    [ -f "$STARSHIP_DST" ] && mv "$STARSHIP_DST" "${STARSHIP_DST}.bak"
    ln -s "$STARSHIP_SRC" "$STARSHIP_DST"
    ok "  ~/.config/starship.toml → $STARSHIP_SRC"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 2. Dotfiles shell
# ══════════════════════════════════════════════════════════════════════════════
info "Installation des dotfiles shell..."

SHELL_FILES=".bashrc .bash_aliases .bash_profile .bash_logout .gitconfig .vimrc .xprofile"

for f in $SHELL_FILES; do
    src="$CONFIG/$f"
    dst="$HOME/$f"

    if [ ! -f "$src" ]; then
        warn "  $src manquant (skip)"
        continue
    fi

    if [ -f "$dst" ] && [ ! -L "$dst" ]; then
        warn "  $dst existe. Sauvegarde → ${dst}.bak"
        cp "$dst" "${dst}.bak"
    fi

    ln -sf "$src" "$dst"
    ok "  ~/$f → $src"
done

# ══════════════════════════════════════════════════════════════════════════════
# 3. GDB
# ══════════════════════════════════════════════════════════════════════════════
info "Configuration de GDB..."
ln -sf "$CONFIG/gdbinit" "$HOME/.gdbinit"
ok "  ~/.gdbinit → $CONFIG/gdbinit"

# ══════════════════════════════════════════════════════════════════════════════
# 4. Emacs
# ══════════════════════════════════════════════════════════════════════════════
info "Configuration d'Emacs..."
mkdir -p "$HOME/.emacs.d"
ln -sf "$CONFIG/emacs/init.el" "$HOME/.emacs.d/init.el"
ok "  ~/.emacs.d/init.el → $CONFIG/emacs/init.el"

# ══════════════════════════════════════════════════════════════════════════════
# 5. Clang-format — symlink "current" vers l'année en cours
# ══════════════════════════════════════════════════════════════════════════════
info "Configuration de clang-format..."
CLANG_DIR="$HOME/.config/clang-format"

# Lien C
if [ -f "$CLANG_DIR/clang-format-c-epita-ing1-2025-2026" ]; then
    ln -sf "$CLANG_DIR/clang-format-c-epita-ing1-2025-2026" "$CLANG_DIR/clang-format-c-current"
    ok "  clang-format-c-current → clang-format-c-epita-ing1-2025-2026"
fi

# Lien C++
if [ -f "$CLANG_DIR/clang-format-cxx-epita-ing1-2025-2026" ]; then
    ln -sf "$CLANG_DIR/clang-format-cxx-epita-ing1-2025-2026" "$CLANG_DIR/clang-format-cxx-current"
    ok "  clang-format-cxx-current → clang-format-cxx-epita-ing1-2025-2026"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 6. Optimot — symlink XCompose
# ══════════════════════════════════════════════════════════════════════════════
info "Configuration du clavier Optimot..."
if [ -f "$CONFIG/Optimot/Optimot.xkb" ]; then
    ok "  Optimot.xkb présent — sera chargé au démarrage i3 via load_keyboard.sh"
fi
# Symlink .XCompose dès l'install (pas attendre load_keyboard.sh)
if [ -f "$CONFIG/Optimot/.XCompose" ]; then
    ln -sf "$CONFIG/Optimot/.XCompose" "$HOME/.XCompose"
    ok "  ~/.XCompose → $CONFIG/Optimot/.XCompose"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 7. Rendre les scripts exécutables
# ══════════════════════════════════════════════════════════════════════════════
info "Permissions des scripts..."
find "$CONFS/scripts" -type f -name "*.sh" -exec chmod +x {} \;
ok "  Tous les scripts *.sh sont exécutables"

# ══════════════════════════════════════════════════════════════════════════════
# 8. Wallpapers
# ══════════════════════════════════════════════════════════════════════════════
info "Wallpapers..."
WALLPAPERS_REPO="https://github.com/yinpi21/yinpi-wallpapers.git"
WALLPAPERS_DIR="$CONFS/wallpapers"

if [ ! -d "$WALLPAPERS_DIR" ]; then
    if git clone "$WALLPAPERS_REPO" "$WALLPAPERS_DIR" > /dev/null 2>&1; then
        ok "  Wallpapers clonés → $WALLPAPERS_DIR"
    else
        warn "  Impossible de cloner les wallpapers (pas de réseau ?)"
        mkdir -p "$WALLPAPERS_DIR"
    fi
else
    ok "  Wallpapers déjà présents (skip)"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 9. Firefox — profil persisté sur AFS
# ══════════════════════════════════════════════════════════════════════════════
info "Firefox (profil AFS)..."

# Vérifier que ~/afs est bien un filesystem AFS avant de déplacer le profil.
# Si AFS n'est pas encore monté, le profil finirait sur le disque local et
# serait perdu à la prochaine session.
AFS_FS_TYPE=$(df --output=fstype "$HOME/afs" 2>/dev/null | tail -1 | tr -d ' ')
if [ "$AFS_FS_TYPE" != "afs" ]; then
    warn "  AFS non monté (type: ${AFS_FS_TYPE:-?}) — profil Firefox ignoré"
    warn "  Relancer install.sh une fois AFS disponible pour le configurer"
else
    AFS_MOZILLA="$(dirname "$CONFS")/.mozilla"
    LOCAL_MOZILLA="$HOME/.mozilla"

    mkdir -p "$AFS_MOZILLA"

    if [ -L "$LOCAL_MOZILLA" ]; then
        ok "  ~/.mozilla déjà symlinké → $(readlink "$LOCAL_MOZILLA")"
    elif [ -d "$LOCAL_MOZILLA" ] && [ ! -L "$LOCAL_MOZILLA" ]; then
        warn "  ~/.mozilla existe en local — migration vers AFS..."
        cp -r "$LOCAL_MOZILLA/." "$AFS_MOZILLA/"
        rm -rf "$LOCAL_MOZILLA"
        ln -s "$AFS_MOZILLA" "$LOCAL_MOZILLA"
        ok "  Profil migré et symlinké → $AFS_MOZILLA"
    else
        ln -s "$AFS_MOZILLA" "$LOCAL_MOZILLA"
        ok "  ~/.mozilla → $AFS_MOZILLA"
    fi
fi

# ══════════════════════════════════════════════════════════════════════════════
echo ""
info "Installation terminée !"
printf "${GREEN}Relance i3 (mod+Shift+r) ou déconnecte-toi pour appliquer.${NC}\n"
printf "${YELLOW}N'oublie pas de lancer : matugen image <wallpaper> pour générer les couleurs.${NC}\n"
