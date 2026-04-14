# ────────────────────────────────────────────────
# Aliases & fonctions — EPITA
# ────────────────────────────────────────────────

# Git raccourci
alias g='git'

# ── AFS / EPITA ──────────────────────────────────────────────────────────────

epimount() {
    # --- CONFIGURATION ---
    local USER="frederic.lin"
    local REALM="CRI.EPITA.FR"
    local SERVER="ssh.cri.epita.fr"
    local MOUNT_POINT="$HOME/AFS"
    local KEYTAB="$HOME/.private.keytab"
    local REMOTE_PATH="/afs/cri.epita.fr/user/${USER:0:1}/${USER:0:2}/$USER/u/"

    # --- 1. KERBEROS (Ticket) ---
    if ! klist -s; then
        echo -e "\033[1;33m🔑 Authentification Kerberos (via Keytab)...\033[0m"

        kinit -f -k -t "$KEYTAB" "$USER@$REALM" 2>/dev/null

        if [ $? -ne 0 ]; then
            echo -e "\033[1;31m❌ Le Keytab semble invalide (mot de passe expiré ?).\033[0m"
            read -p "Voulez-vous le régénérer maintenant ? (o/n) " -n 1 -r
            echo ""

            if [[ $REPLY =~ ^[Oo]$ ]]; then
                read -s -p "Entrez votre mot de passe EPITA actuel : " PASS
                echo ""

                printf "addent -password -p %s@%s -k 1 -e aes256-cts-hmac-sha1-96\n%s\nwkt %s\nquit" \
                       "$USER" "$REALM" "$PASS" "$KEYTAB" | ktutil

                if [ $? -eq 0 ]; then
                    echo -e "\033[1;32m✅ Keytab régénéré.\033[0m"
                    kinit -f -k -t "$KEYTAB" "$USER@$REALM"
                    if [ $? -ne 0 ]; then
                        echo -e "\033[1;31m❌ Toujours impossible de s'authentifier.\033[0m"
                        return 1
                    fi
                else
                    echo -e "\033[1;31m❌ Erreur de génération du Keytab.\033[0m"
                    return 1
                fi
            else
                echo "Annulation."
                return 1
            fi
        fi
    fi

    # --- 2. MONTAGE SSHFS ---
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
    fi

    if mount | grep -q "$MOUNT_POINT"; then
        fusermount -u "$MOUNT_POINT" 2>/dev/null
    fi

    echo -e "\033[1;34m📂 Connexion au serveur...\033[0m"
    sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,idmap=user,GSSAPIAuthentication=yes \
          "$SERVER:$REMOTE_PATH" "$MOUNT_POINT"

    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m✅ Succès ! AFS monté dans $MOUNT_POINT\033[0m"
    else
        echo -e "\033[1;31m❌ Échec du montage.\033[0m"
    fi
}

epiunmount() {
    fusermount -u "$HOME/AFS"
    echo -e "\033[1;32m🔒 AFS démonté.\033[0m"
}

# ── Git ───────────────────────────────────────────────────────────────────────

# Aller à la racine du repo git courant
gr() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$root" ]; then
        cd "$root"
    else
        echo "❌ Pas dans un dépôt Git."
    fi
}
