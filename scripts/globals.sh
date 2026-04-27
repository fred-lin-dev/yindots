# BRANCH
BRANCH="main"

# COLORS
BLACK="\033[30m"
WHITE="\033[97m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
GRAY="\033[90m"
NC="\033[0m"

# CONFIG DIRECTORIES
AFS="$HOME/afs"
CONFS="$AFS/.confs"
CFG="$CONFS/Config"
CONFIG="$CFG/config"
SCRIPTS="$CONFS/scripts"
YINDOTS="$CONFS"
WALLPAPERS="$CONFS/wallpapers"

# URLS
REPO_YINDOTS="https://github.com/fred-lin-dev/yindots.git"
RAW_REPO_YINDOTS="https://raw.githubusercontent.com/fred-lin-dev/yindots/refs/heads/$BRANCH/"
REPO_WALLPAPER="git@github.com:fred-lin-dev/yinpi-wallpaper.git"

# VERSION
VERSION_FILE="$CONFS/version"
VERSION=0
[ -f "$VERSION_FILE" ] && VERSION=$(cat "$VERSION_FILE")

REPO_VERSION_FILE="/tmp/yindots_repo_version"
if ! [ -f "$REPO_VERSION_FILE" ]; then
    curl -Ls "${RAW_REPO_YINDOTS}version" > "$REPO_VERSION_FILE" 2>/dev/null
fi
REPO_VERSION="$(cat $REPO_VERSION_FILE 2>/dev/null || echo 0)"
