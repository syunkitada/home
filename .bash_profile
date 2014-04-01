# -------------------------------------------------------------
# environment

# for gnupack on windows
if [ `uname -o` = "Cygwin" ]; then
	plink="$HOME/Desktop/cygwin/putty/plink"
	plink_exe=${plink/$HOME/$HOMEPATH}.exe
	plink_exe=${plink_exe//\//\\}
    alias exp='explorer .'
    alias plink="${plink} -ssh -A -l `whoami`"
    export GIT_SSH=$plink_exe
fi

# basic
export TZ=Asia/Tokyo
export TERM='xterm-256color'

# history
# ignoreboth: ignore space and dups
export HISTCONTROL="ignoreboth"
export HISTFILESIZE="4096"
export HISTSIZE="4096"

# set editor
export EDITOR="/usr/bin/vim"


# -------------------------------------------------------------
# terminal
source ~/.git-completion.bash
source ~/.git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true

# prompt
PS1='
\[\e[0;37m\](\t)\[\e[00m\] [\u@\[\e[1;31m\]\H\[\e[00m\]:\w \[\e[1;31m\]$(__git_ps1 "(%s)")\[\e[00m\] | Retv:${?} Jobs:\j]
$ '

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
alias vimsh='vim -c :VimShell'
alias vimf='vim -c :VimFiler'

# alias for misc
alias grep='grep --color'

# alias for some shortcuts for different directory listings
alias ls='ls -hF --color=always --show-control-chars'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias s='screen'


# -------------------------------------------------------------
# end .bash_profile
#
# if you want to add your settings, please describe below.
# -------------------------------------------------------------

