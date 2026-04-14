#
# ~/.bash_profile
#

export EDITOR=vim
export VISUAL=vim

# Méthode de saisie XIM — touches mortes et XCompose (Optimot)
export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim
export XMODIFIERS="@im=none"
export XCOMPOSEFILE="$HOME/.XCompose"

[[ -f ~/.bashrc ]] && . ~/.bashrc
