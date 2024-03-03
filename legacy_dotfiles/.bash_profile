# -------------------------------------------------------------
# environment

# basic
export TZ=Asia/Tokyo
export LANG=C.UTF-8

# history
export HISTCONTROL="ignoreboth"
export HISTFILESIZE="4096"
export HISTSIZE="4096"

# -------------------------------------------------------------
# terminal

# prompt
PS1="
\[\e[0;37m\]\t [\$?,\\j] \u@\e[1;31m\]\[\H\[\e[00m\]:\w
$ "
export PS1=$PS1

# -------------------------------------------------------------
# alias

# for interactive operation
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# alias for misc
alias grep="grep --color"

# alias for some shortcuts for different directory listings
alias ls="ls -hF --color=always --show-control-chars"

# arias for screen and tmux
alias t="tmux"
alias ta="tmux a"
alias tl="tmux ls"

command -v zsh && exec zsh || echo "zsh is not installed"
