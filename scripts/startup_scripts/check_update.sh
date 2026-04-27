#!/bin/sh

. "$HOME/afs/.confs/scripts/globals.sh"

if [ "$VERSION" -lt "$REPO_VERSION" ] 2>/dev/null; then
    dunstify "Mise à jour yindots disponible !" \
        "Lance update-conf\n(Installée: $VERSION | Dispo: $REPO_VERSION)" \
        -t 60000
fi
