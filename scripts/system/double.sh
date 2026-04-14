#!/bin/sh
# Ouvre un nouveau terminal alacritty dans le dossier courant de la fenêtre active

ID=$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}')
PID=$(xprop -id "$ID" _NET_WM_PID | awk '{print $3}')
CHILD_PID=$(pgrep -P "$PID")

if [ -n "$CHILD_PID" ]; then
    CWD=$(readlink -f "/proc/$CHILD_PID/cwd")
else
    CWD=$(readlink -f "/proc/$PID/cwd")
fi

alacritty --working-directory "$CWD"
