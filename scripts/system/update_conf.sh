#!/bin/sh
# Met à jour la config en re-clonant dans un dossier temporaire
# puis en copiant les fichiers dans ~/afs/.confs/

source "$HOME/afs/.confs/scripts/globals.sh"

TMP_DIR="$HOME/config_from_yinpi_tmp"

printf "${BLUE}::${NC} %-42s" "Téléchargement de la dernière version..."
rm -rf "$TMP_DIR"
if git clone -b "$BRANCH" "$REPO_CONFS" "$TMP_DIR" > /dev/null 2>&1; then
    printf "[${GREEN}OK${NC}]\n"
else
    printf "[${RED}KO${NC}]\n"
    exit 1
fi

printf "${BLUE}::${NC} %-42s" "Déploiement dans ~/afs/.confs/..."
for item in Config scripts version install.sh check.sh; do
    t="$CONFS/$item"
    if [ -L "$t" ]; then
        unlink "$t"
    elif [ -d "$t" ]; then
        rm -rf "$t"
    elif [ -f "$t" ]; then
        rm -f "$t"
    fi
done
cp -r "$TMP_DIR/Config"     "$CONFS/"
cp -r "$TMP_DIR/scripts"    "$CONFS/"
cp    "$TMP_DIR/version"    "$CONFS/"
cp    "$TMP_DIR/install.sh" "$CONFS/"
cp    "$TMP_DIR/check.sh"   "$CONFS/"
chmod +x "$CONFS/install.sh" "$CONFS/check.sh"
find "$CONFS/scripts" -name "*.sh" -exec chmod +x {} \;
printf "[${GREEN}OK${NC}]\n"

printf "${BLUE}::${NC} %-42s" "Nettoyage..."
rm -rf "$TMP_DIR"
printf "[${GREEN}OK${NC}]\n"

printf "${GREEN}✅ Config mise à jour avec succès.${NC}\n"
