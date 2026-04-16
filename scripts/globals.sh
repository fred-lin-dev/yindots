# ── globals.sh — variables centralisées ──────────────────────────────────────
# Sourcé par tous les scripts : source "$HOME/afs/.confs/scripts/globals.sh"

# ── Couleurs ANSI ─────────────────────────────────────────────────────────────
BLACK="\033[30m"
WHITE="\033[97m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
GRAY="\033[90m"
LIGHT_GRAY="\033[37m"
LIGHT_RED="\033[91m"
LIGHT_GREEN="\033[92m"
LIGHT_YELLOW="\033[93m"
LIGHT_BLUE="\033[94m"
LIGHT_MAGENTA="\033[95m"
LIGHT_CYAN="\033[96m"
NC="\033[0m"

# ── Chemins de la config ───────────────────────────────────────────────────────
AFS="$HOME/afs"
CONFS="$AFS/.confs"
CONFIG="$CONFS/Config/config"
SCRIPTS="$CONFS/scripts"
WALLPAPERS="$CONFS/wallpapers"

# ── URLs du repo (à mettre à jour avec ton propre repo) ───────────────────────
BRANCH="main"
REPO_CONFS="https://github.com/yinpi21/yindots.git"
RAW_REPO_CONFS="https://raw.githubusercontent.com/yinpi21/yindots/refs/heads/$BRANCH/"

# ── Version (pour check_update.sh) ───────────────────────────────────────────
VERSION_FILE="$CONFS/version"
VERSION=0

if [ -f "$VERSION_FILE" ]; then
    VERSION=$(cat "$VERSION_FILE")
fi

REPO_VERSION_FILE="/tmp/confs_repo_version"
if ! [ -f "$REPO_VERSION_FILE" ]; then
    curl -Ls "$RAW_REPO_CONFS/version" > "$REPO_VERSION_FILE" 2>/dev/null
fi

REPO_VERSION="$(cat "$REPO_VERSION_FILE" 2>/dev/null || echo 0)"
