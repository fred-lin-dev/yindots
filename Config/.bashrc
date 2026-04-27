#
# ~/.bashrc — yindots (NixOS EPITA)
#

[[ $- != *i* ]] && return

# ── PATH ──────────────────────────────────────────────────────────────────────
[ -d "$HOME/afs/bin" ]   && export PATH="$HOME/afs/bin:$PATH"
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.nix-profile/bin" ] && export PATH="$HOME/.nix-profile/bin:$PATH"

# ── ENVIRONNEMENT ─────────────────────────────────────────────────────────────
export LANG=en_US.utf8
export NNTPSERVER="news.epita.fr"
export EDITOR=vim
export VISUAL=vim
export PGDATA="$HOME/postgres_data"
export PGHOST="/tmp"

# ── HISTORIQUE ────────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
shopt -s autocd
shopt -s cdspell

# ── COMPLÉTION ────────────────────────────────────────────────────────────────
bind 'set completion-ignore-case on'
bind "set colored-stats on"
bind "set visible-stats on"
bind "set colored-completion-prefix on"
bind "set show-all-if-ambiguous on"
bind "set menu-complete-display-prefix on"

[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# ── COULEURS ──────────────────────────────────────────────────────────────────
if command -v dircolors &>/dev/null; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

export LS_COLORS="di=1;34:ln=1;36:ex=1;32:fi=0"

# ── ALIASES ───────────────────────────────────────────────────────────────────
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"

# ── FZF (nix-profile) ─────────────────────────────────────────────────────────
[ -f "$HOME/.nix-profile/share/fzf/completion.bash" ]   && source "$HOME/.nix-profile/share/fzf/completion.bash"
[ -f "$HOME/.nix-profile/share/fzf/key-bindings.bash" ] && source "$HOME/.nix-profile/share/fzf/key-bindings.bash"

export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ── ZOXIDE ────────────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
    alias cd='z'
fi

# ── PROMPT ────────────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
else
    PS1='(づ ◕‿‿◕)づ \[\e[32m\]$( [ "$PWD" = "$HOME" ] && echo "yinpi" || basename "$PWD" )\[\e[0m\]$ '
fi

# ── YINDOTS ───────────────────────────────────────────────────────────────────
update-conf() {
    sh "$HOME/afs/.confs/scripts/system/update_yindots.sh"
    [ $? -eq 0 ] && source "$HOME/.bashrc"
}

alias reset-conf="$HOME/afs/.confs/scripts/system/remove_yindots.sh"
