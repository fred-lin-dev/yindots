#!/bin/sh
# Vérifie si une mise à jour de la config est disponible

source "$HOME/afs/.confs/scripts/globals.sh"

if [ "$VERSION" -lt "$REPO_VERSION" ] 2>/dev/null; then
    dunstify "Mise à jour disponible !" \
        "Lance update-conf pour mettre à jour\n(Actuel: $VERSION, Dernier: $REPO_VERSION)" \
        -t 60000
fi
