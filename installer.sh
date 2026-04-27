#!/bin/sh
# ══════════════════════════════════════════════════════════════════════════════
#   installer.sh — Bootstrap yindots sur une machine EPITA
#
#   Usage (one-liner depuis n'importe quelle machine EPITA) :
#     curl -Ls https://raw.githubusercontent.com/yinpi21/yindots/main/installer.sh | sh
#
#   Clone dans un dossier temporaire, déploie dans ~/afs/.confs/,
#   puis supprime le temporaire. Les fichiers existants (.ssh, .mozilla, etc.)
#   ne sont pas touchés.
# ══════════════════════════════════════════════════════════════════════════════

BRANCH="main"
REPO_URL="https://github.com/yinpi21/yindots.git"
TMP_DIR="$HOME/yindots_tmp"
TARGET_DIR="$HOME/afs/.confs"

GREEN=$(printf '\033[0;32m')
BLUE=$(printf '\033[0;34m')
RED=$(printf '\033[0;31m')
NC=$(printf '\033[0m')

printf "${BLUE}::${NC} %-42s" "Clonage du repo ($BRANCH)..."
rm -rf "$TMP_DIR"
if git clone -b "$BRANCH" "$REPO_URL" "$TMP_DIR" > /dev/null 2>&1; then
    printf "[${GREEN}OK${NC}]\n"
else
    printf "[${RED}KO${NC}]\n"
    exit 1
fi

printf "${BLUE}::${NC} %-42s" "Déploiement dans ~/afs/.confs/..."
mkdir -p "$TARGET_DIR"

ITEMS="Config scripts version install.sh check.sh installer.sh"
BACKUP_DIR="$TARGET_DIR/.install_backup_$$"
mkdir -p "$BACKUP_DIR"

for item in $ITEMS; do
    t="$TARGET_DIR/$item"
    if [ -L "$t" ]; then
        unlink "$t"
    elif [ -e "$t" ]; then
        mv "$t" "$BACKUP_DIR/"
    fi
done

copy_failed=0
cp -r "$TMP_DIR/Config"      "$TARGET_DIR/" || copy_failed=1
cp -r "$TMP_DIR/scripts"     "$TARGET_DIR/" || copy_failed=1
cp    "$TMP_DIR/version"     "$TARGET_DIR/" || copy_failed=1
cp    "$TMP_DIR/install.sh"  "$TARGET_DIR/" || copy_failed=1
cp    "$TMP_DIR/check.sh"    "$TARGET_DIR/" || copy_failed=1
cp    "$TMP_DIR/installer.sh" "$TARGET_DIR/" || copy_failed=1

if [ "$copy_failed" -eq 0 ]; then
    chmod +x "$TARGET_DIR/install.sh" "$TARGET_DIR/check.sh" "$TARGET_DIR/installer.sh"
    find "$TARGET_DIR/scripts" -name "*.sh" -exec chmod +x {} \;
    rm -rf "$BACKUP_DIR"
    printf "[${GREEN}OK${NC}]\n"
else
    for item in $ITEMS; do
        [ -e "$BACKUP_DIR/$item" ] && mv "$BACKUP_DIR/$item" "$TARGET_DIR/"
    done
    rm -rf "$BACKUP_DIR"
    printf "[${RED}KO (restauré depuis backup)${NC}]\n"
    rm -rf "$TMP_DIR"
    exit 1
fi

printf "${BLUE}::${NC} %-42s" "Nettoyage..."
rm -rf "$TMP_DIR"
printf "[${GREEN}OK${NC}]\n"

"$TARGET_DIR/install.sh"
