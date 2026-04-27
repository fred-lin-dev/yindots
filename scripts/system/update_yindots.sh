#!/bin/sh
# Met à jour yindots depuis le repo GitHub

AFS="$HOME/afs"
CONFS="$AFS/.confs"
TMP_DIR="$HOME/yindots_tmp"
REPO_URL="https://github.com/yinpi21/yindots.git"
BRANCH="main"

GREEN=$(printf '\033[0;32m')
BLUE=$(printf '\033[0;34m')
RED=$(printf '\033[0;31m')
NC=$(printf '\033[0m')

printf "${BLUE}::${NC} %-42s" "Récupération des mises à jour..."
rm -rf "$TMP_DIR"
if git clone -b "$BRANCH" "$REPO_URL" "$TMP_DIR" > /dev/null 2>&1; then
    printf "[${GREEN}OK${NC}]\n"
else
    printf "[${RED}KO${NC}]\n"
    exit 1
fi

printf "${BLUE}::${NC} %-42s" "Déploiement..."
cp -r "$TMP_DIR/Config"      "$CONFS/" && \
cp -r "$TMP_DIR/scripts"     "$CONFS/" && \
cp    "$TMP_DIR/version"     "$CONFS/" && \
cp    "$TMP_DIR/install.sh"  "$CONFS/" && \
cp    "$TMP_DIR/check.sh"    "$CONFS/" && \
cp    "$TMP_DIR/installer.sh" "$CONFS/" || { printf "[${RED}KO${NC}]\n"; exit 1; }

find "$CONFS/scripts" -name "*.sh" -exec chmod +x {} \;
chmod +x "$CONFS/install.sh" "$CONFS/check.sh" "$CONFS/installer.sh"

printf "[${GREEN}OK${NC}]\n"

printf "${BLUE}::${NC} %-42s" "Nettoyage..."
rm -rf "$TMP_DIR"
printf "[${GREEN}OK${NC}]\n"

printf "\n${GREEN}yindots mis à jour ! Relance i3 (Mod+Shift+r).${NC}\n"
