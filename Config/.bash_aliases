# ── Git ───────────────────────────────────────────────────────────────────────
alias g='git'

# Fonction Git Root
gr() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$root" ]; then cd "$root"
    else echo "Pas dans un dépôt Git."; fi
}
