#!/bin/sh
# ══════════════════════════════════════════════════════════════════════════════
#   check.sh — Vérifie que la config EPITA est bien installée
#   Usage : bash ~/afs/.confs/check.sh
# ══════════════════════════════════════════════════════════════════════════════

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
NC="\033[0m"

CONFS="$(cd "$(dirname "$0")" && pwd)"
OK=0
FAIL=0
WARN=0

ok()   { printf "  ${GREEN}✓${NC} %s\n" "$1";  OK=$((OK+1)); }
fail() { printf "  ${RED}✗${NC} %s\n" "$1";    FAIL=$((FAIL+1)); }
warn() { printf "  ${YELLOW}!${NC} %s\n" "$1"; WARN=$((WARN+1)); }

check_symlink() {
    local label="$1"
    local path="$2"
    if [ -L "$path" ] && [ -e "$path" ]; then
        ok "$label → $(readlink "$path")"
    elif [ -e "$path" ] && [ ! -L "$path" ]; then
        warn "$label existe mais n'est PAS un symlink"
    else
        fail "$label manquant ou lien cassé"
    fi
}

check_exec() {
    local label="$1"
    local path="$2"
    if [ -x "$path" ]; then
        ok "$label est exécutable"
    elif [ -f "$path" ]; then
        warn "$label présent mais non exécutable (AFS mount ?)"
    else
        fail "$label absent"
    fi
}

check_cmd() {
    local label="$1"
    local cmd="$2"
    if command -v "$cmd" > /dev/null 2>&1; then
        ok "$label installé ($(command -v "$cmd"))"
    else
        warn "$label non trouvé dans le PATH"
    fi
}

# ── Repo ──────────────────────────────────────────────────────────────────────
printf "\n${BLUE}── Repo ─────────────────────────────────────────────────────${NC}\n"
if [ -d "$CONFS/.git" ]; then
    ok "Repo présent dans ~/afs/.confs/"
    BRANCH=$(git -C "$CONFS" rev-parse --abbrev-ref HEAD 2>/dev/null)
    ok "Branche : $BRANCH"
else
    warn "~/afs/.confs/ n'est pas un repo git (installer.sh copie sans cloner)"
fi

# ── Symlinks ~/.config/ ───────────────────────────────────────────────────────
printf "\n${BLUE}── Symlinks ~/.config/ ──────────────────────────────────────${NC}\n"
for app in alacritty picom polybar rofi matugen clang-format dunst gtk-3.0 gtk-4.0 qt5ct qt6ct i3; do
    check_symlink "~/.config/$app" "$HOME/.config/$app"
done

# ── Dotfiles shell ────────────────────────────────────────────────────────────
printf "\n${BLUE}── Dotfiles shell ───────────────────────────────────────────${NC}\n"
for f in .bashrc .bash_aliases .bash_profile .bash_logout .gitconfig .vimrc; do
    check_symlink "~/$f" "$HOME/$f"
done

# ── Autres configs ────────────────────────────────────────────────────────────
printf "\n${BLUE}── Autres configs ───────────────────────────────────────────${NC}\n"
check_symlink "~/.gdbinit"        "$HOME/.gdbinit"
check_symlink "~/.emacs.d/init.el" "$HOME/.emacs.d/init.el"

# ── Clang-format symlinks ─────────────────────────────────────────────────────
printf "\n${BLUE}── Clang-format ─────────────────────────────────────────────${NC}\n"
check_symlink "clang-format-c-current"   "$HOME/.config/clang-format/clang-format-c-current"
check_symlink "clang-format-cxx-current" "$HOME/.config/clang-format/clang-format-cxx-current"

# ── Scripts exécutables ───────────────────────────────────────────────────────
printf "\n${BLUE}── Scripts ──────────────────────────────────────────────────${NC}\n"
for s in \
    scripts/system/double.sh \
    scripts/system/open_afs.sh \
    scripts/system/afs_cleaner.sh \
    scripts/system/brightness.sh \
    scripts/system/i3lock.sh \
    scripts/system/update_conf.sh \
    scripts/menus/power_menu.sh \
    scripts/menus/epita_menu.sh \
    scripts/startup_scripts/startup.sh \
    scripts/startup_scripts/aklogger.sh \
    scripts/wallpaper_scripts/change_wallpaper.sh \
    Config/Optimot/load_keyboard.sh; do
    check_exec "$s" "$CONFS/$s"
done

# ── Commandes nix installées ──────────────────────────────────────────────────
printf "\n${BLUE}── Packages nix ─────────────────────────────────────────────${NC}\n"
for cmd in autotiling picom polybar rofi alacritty feh matugen dunst flameshot fzf fd zoxide bat emacs; do
    check_cmd "$cmd" "$cmd"
done

# ── Matugen — fichiers générés ────────────────────────────────────────────────
printf "\n${BLUE}── Matugen (couleurs générées) ──────────────────────────────${NC}\n"
GENERATED="\
$HOME/.config/i3/colors.conf
$HOME/.config/polybar/colors.ini
$HOME/.config/rofi/colors.rasi
$HOME/.config/alacritty/colors.toml
$HOME/.config/dunst/dunstrc"

for f in $GENERATED; do
    if [ -f "$f" ]; then
        ok "$f"
    else
        warn "$f absent — lance : matugen image <wallpaper>"
    fi
done

# ── Résumé ────────────────────────────────────────────────────────────────────
printf "\n${BLUE}─────────────────────────────────────────────────────────────${NC}\n"
printf "  ${GREEN}✓ $OK OK${NC}   ${RED}✗ $FAIL ERREURS${NC}   ${YELLOW}! $WARN AVERTISSEMENTS${NC}\n\n"

if [ "$FAIL" -gt 0 ]; then
    printf "${RED}Des erreurs ont été détectées. Relance install.sh :${NC}\n"
    printf "  bash ~/afs/.confs/install.sh\n\n"
elif [ "$WARN" -gt 0 ]; then
    printf "${YELLOW}Config installée avec des avertissements.${NC}\n"
    printf "Si matugen n'a pas encore tourné :\n"
    printf "  matugen image ~/afs/.confs/wallpapers/default.jpg\n\n"
else
    printf "${GREEN}Tout est en ordre !${NC}\n\n"
fi
