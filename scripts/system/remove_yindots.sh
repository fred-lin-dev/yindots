#!/bin/sh

. "$HOME/afs/.confs/scripts/globals.sh"

DEFAULT_DOTFILES="https://gitlab.cri.epita.fr/forge/packages/sm-default-dotfiles.git"

printf "${BLUE}┌──────────────────────────────────────────┐${NC}\n"
printf "${BLUE}│             REMOVING YINDOTS             │${NC}\n"
printf "${BLUE}└──────────────────────────────────────────┘${NC}\n"

# ── 1. Backup wallpapers persos ───────────────────────────────────────────────
printf "${BLUE}::${NC} %-42s" "Sauvegarde des fichiers persos..."
tmp_chk=$(mktemp -d)

if git clone --depth 1 -b "$BRANCH" "$REPO_YINDOTS" "$tmp_chk/repo" >/dev/null 2>&1 && \
   git clone --depth 1 "$REPO_WALLPAPER" "$tmp_chk/walls" >/dev/null 2>&1; then

    if [ -d "$WALLPAPERS" ]; then
        mkdir -p "$AFS/user_wallpapers"
        ls "$tmp_chk/walls" > "$tmp_chk/defaults_walls.txt" 2>/dev/null
        for wp in "$WALLPAPERS"/*; do
            [ -e "$wp" ] || continue
            fname="${wp##*/}"
            [ "$fname" = ".git" ] && continue
            grep -Fqx "$fname" "$tmp_chk/defaults_walls.txt" || mv "$wp" "$AFS/user_wallpapers/"
        done
    fi

    if [ -d "$SCRIPTS/startup_scripts" ]; then
        mkdir -p "$AFS/user_scripts"
        ls "$tmp_chk/repo/scripts/startup_scripts" > "$tmp_chk/defaults_scripts.txt" 2>/dev/null
        for sc in "$SCRIPTS/startup_scripts"/*; do
            [ -e "$sc" ] || continue
            fname="${sc##*/}"
            grep -Fqx "$fname" "$tmp_chk/defaults_scripts.txt" || mv "$sc" "$AFS/user_scripts/"
        done
    fi

    rm -rf "$tmp_chk"
    printf "[${GREEN}OK${NC}]\n"
else
    rm -rf "$tmp_chk"
    printf "[${RED}KO${NC}]\n"
    exit 1
fi

# ── 2. Suppression des symlinks yindots ───────────────────────────────────────
printf "${BLUE}::${NC} %-42s" "Suppression des symlinks..."
for f in .bashrc .bash_aliases .bash_profile .bash_logout .gitconfig .vimrc .xprofile .gdbinit .XCompose; do
    [ -L "$HOME/$f" ] && unlink "$HOME/$f"
done
[ -L "$HOME/.emacs.d/init.el" ] && unlink "$HOME/.emacs.d/init.el"
for app in alacritty i3 dunst rofi picom polybar matugen qt5ct qt6ct gtk-3.0 gtk-4.0 clang-format starship.toml flameshot; do
    [ -L "$HOME/.config/$app" ] && unlink "$HOME/.config/$app"
done
printf "[${GREEN}OK${NC}]\n"

# ── 3. Restauration des dotfiles EPITA par défaut ─────────────────────────────
printf "${BLUE}::${NC} %-42s" "Restauration dotfiles EPITA..."
tmp=$(mktemp -d)
if git clone "$DEFAULT_DOTFILES" "$tmp" >/dev/null 2>&1; then
    cp -Rf "$tmp/"*     "$CONFS/" 2>/dev/null
    cp -Rf "$tmp/".[!.]* "$CONFS/" 2>/dev/null
    rm -rf "$CONFS/.git"
    rm -rf "$tmp"
    printf "[${GREEN}OK${NC}]\n"
else
    rm -rf "$tmp"
    printf "[${RED}KO${NC}]\n"
    exit 1
fi

# ── 4. Nettoyage des fichiers yindots ─────────────────────────────────────────
printf "${BLUE}::${NC} %-42s" "Nettoyage..."
for f in \
    "$CONFS/Config" \
    "$CONFS/scripts" \
    "$CONFS/wallpapers" \
    "$CONFS/version" \
    "$CONFS/install.sh" \
    "$CONFS/installer.sh" \
    "$CONFS/check.sh"
do
    rm -rf "$f"
done
printf "[${GREEN}OK${NC}]\n"

# ── 5. Restart ────────────────────────────────────────────────────────────────
pkill polybar >/dev/null 2>&1 || true
pkill picom   >/dev/null 2>&1 || true
pkill dunst   >/dev/null 2>&1 || true
i3-config-wizard >/dev/null 2>&1 || true
i3-msg restart  >/dev/null 2>&1 || true

printf "\n${GREEN}Yindots désinstallé. Reconnecte-toi pour finir.${NC}\n"
