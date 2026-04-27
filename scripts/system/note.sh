#!/bin/sh
# Ouvre une note persistante dans vim (singleton : une seule instance)

. "$HOME/afs/.confs/scripts/globals.sh"

LOCK_FILE="/tmp/note.lock"
NOTE_FILE="$AFS/.note.txt"

if [ ! -f "$LOCK_FILE" ] || ! kill -s 0 "$(cat "$LOCK_FILE")" 2>/dev/null; then
    rm -f "${NOTE_FILE}.swp"
    echo "$PPID" > "$LOCK_FILE"
    vim "$NOTE_FILE" +startinsert
    rm -f "$LOCK_FILE"
fi
