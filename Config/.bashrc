#
# ~/.bashrc — config EPITA (NixOS)
#

# ────────────────────────────────────────────────
# 1. Quitte immédiatement si le shell n'est pas interactif
# ────────────────────────────────────────────────
[[ $- != *i* ]] && return

# ────────────────────────────────────────────────
# 2. Variables EPITA
# ────────────────────────────────────────────────
export PGDATA="$HOME/postgres_data"
export PGHOST="/tmp"
export LANG=en_US.utf8
export NNTPSERVER="news.epita.fr"

if [ -d ~/afs/bin ]; then
    export PATH=~/afs/bin:$PATH
fi
if [ -d ~/.local/bin ]; then
    export PATH=~/.local/bin:$PATH
fi

# ────────────────────────────────────────────────
# 3. Éditeurs par défaut
# ────────────────────────────────────────────────
export EDITOR=vim
export VISUAL=vim

# ────────────────────────────────────────────────
# 4. Historique
# ────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# ────────────────────────────────────────────────
# 5. Navigation
# ────────────────────────────────────────────────
shopt -s autocd
shopt -s cdspell

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ────────────────────────────────────────────────
# 6. Couleurs & alias système
# ────────────────────────────────────────────────
if command -v dircolors &>/dev/null; then
    if [ -r "$HOME/.dircolors" ]; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
else
    alias ls='ls'
    alias grep='grep'
    alias fgrep='fgrep'
    alias egrep='egrep'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

export LS_COLORS="di=1;34:ln=1;36:ex=1;32:fi=0"

# ────────────────────────────────────────────────
# 7. Notifications graphiques
# ────────────────────────────────────────────────
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
"$(history | tail -n1 | sed -E '\''s/^\s*[0-9]+\s*//;s/[;&|]\s*alert$//'\'')"'

# ────────────────────────────────────────────────
# 8. Fichier d'alias utilisateur
# ────────────────────────────────────────────────
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

# ────────────────────────────────────────────────
# 9. Prompt — Starship
# ────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# ────────────────────────────────────────────────
# 10. GCC colors
# ────────────────────────────────────────────────
# export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ────────────────────────────────────────────────
# 11. Auto-complétion colorée
# ────────────────────────────────────────────────
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

bind 'set completion-ignore-case on'
bind "set colored-stats on"
bind "set visible-stats on"
bind "set colored-completion-prefix on"
bind "set show-all-if-ambiguous on"
bind "set menu-complete-display-prefix on"

# ────────────────────────────────────────────────
# 12. FZF (chemins NixOS)
# ────────────────────────────────────────────────
# NixOS : fzf peut être dans ~/.nix-profile ou dans le store
if [ -f ~/.nix-profile/share/fzf/completion.bash ]; then
    source ~/.nix-profile/share/fzf/completion.bash
elif [ -f /usr/share/fzf/completion.bash ]; then
    source /usr/share/fzf/completion.bash
fi
if [ -f ~/.nix-profile/share/fzf/key-bindings.bash ]; then
    source ~/.nix-profile/share/fzf/key-bindings.bash
elif [ -f /usr/share/fzf/key-bindings.bash ]; then
    source /usr/share/fzf/key-bindings.bash
fi

if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ────────────────────────────────────────────────
# 13. Gestion de la config EPITA
# ────────────────────────────────────────────────
update-conf() {
    sh "$HOME/afs/.confs/scripts/system/update_conf.sh"
    if [ $? -eq 0 ]; then
        source ~/.bashrc > /dev/null 2>&1
    fi
}

# ────────────────────────────────────────────────
# 14. Zoxide (cd intelligent) — doit rester en dernier
# ────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
    alias cd='z'
fi
