#!/bin/sh
# ══════════════════════════════════════════════════════════════════════════════
#   installer.sh — Bootstrap config EPITA
#
#   Usage (one-liner depuis n'importe quelle machine EPITA) :
#     curl -Ls https://raw.githubusercontent.com/yinpi21/yindots/main/installer.sh | sh
#
#   Approche : clone dans un dossier temporaire, copie dans ~/afs/.confs/,
#   puis supprime le temporaire. Les fichiers existants dans .confs/ (clés SSH,
#   mozilla, etc.) ne sont pas touchés.
# ══════════════════════════════════════════════════════════════════════════════

BRANCH="main"
REPO_URL="https://github.com/yinpi21/yindots.git"
TMP_DIR="$HOME/yindots_tmp"
TARGET_DIR="$HOME/afs/.confs"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# ── Clonage dans le dossier temporaire ───────────────────────────────────────
printf "${BLUE}::${NC} %-42s" "Clonage du repo ($BRANCH)..."
rm -rf "$TMP_DIR"
if git clone -b "$BRANCH" "$REPO_URL" "$TMP_DIR" > /dev/null 2>&1; then
    printf "[${GREEN}OK${NC}]\n"
else
    printf "[${RED}KO${NC}]\n"
    exit 1
fi

# ── Copie dans ~/afs/.confs/ (sans toucher l'existant) ───────────────────────
printf "${BLUE}::${NC} %-42s" "Déploiement dans ~/afs/.confs/..."
mkdir -p "$TARGET_DIR"

# Suppression propre : unlink pour les symlinks, rm pour le reste
for item in Config scripts version install.sh check.sh; do
    t="$TARGET_DIR/$item"
    if [ -L "$t" ]; then
        unlink "$t"
    elif [ -d "$t" ]; then
        rm -rf "$t"
    elif [ -f "$t" ]; then
        rm -f "$t"
    fi
done

cp -r "$TMP_DIR/Config"     "$TARGET_DIR/"
cp -r "$TMP_DIR/scripts"    "$TARGET_DIR/"
cp    "$TMP_DIR/version"    "$TARGET_DIR/"
cp    "$TMP_DIR/install.sh" "$TARGET_DIR/"
cp    "$TMP_DIR/check.sh"   "$TARGET_DIR/"
chmod +x "$TARGET_DIR/install.sh" "$TARGET_DIR/check.sh"
find "$TARGET_DIR/scripts" -name "*.sh" -exec chmod +x {} \;
printf "[${GREEN}OK${NC}]\n"

# ── Nettoyage du dossier temporaire ──────────────────────────────────────────
printf "${BLUE}::${NC} %-42s" "Nettoyage..."
rm -rf "$TMP_DIR"
printf "[${GREEN}OK${NC}]\n"

# ── Lancement de install.sh ───────────────────────────────────────────────────
"$TARGET_DIR/install.sh"
