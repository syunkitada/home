source ~/.git-completion.bash
source ~/.git-prompt.sh

GIT_PS1_SHOWDIRTYSTATE=true

# -------------------------------------------------------------
# environment

if [ `uname -o` = "Cygwin" ]; then
    export GIT_SSH=${HOMEPATH}\\Desktop\\gnupack\\putty-gdi-20130306\\plink.exe
fi

# time zone
export TZ=Asia/Tokyo

# history
# ignoreboth: ignore space and dups
export HISTIGNORE="ls*:history*"
export HISTCONTROL="ignoreboth"
export HISTFILESIZE="4096"
export HISTSIZE="4096"


# -------------------------------------------------------------
# terminal

# prompt
PS1='
\[\e[0;37m\](\t)\[\e[00m\] [\u@\[\e[1;31m\]\H\[\e[00m\]:\w \[\e[1;31m\]$(__git_ps1 "(%s)")\[\e[00m\] | Retv:${?} Jobs:\j]
# '

export PS1=$PS1

# -------------------------------------------------------------
# complete
# complete -d cd


# -------------------------------------------------------------
# alias

# for interactive operation
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# alias for misc
alias grep='grep --color'

# alias for some shortcuts for different directory listings
alias ls='ls -hF --color=always --show-control-chars'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

