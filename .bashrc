# -------------------------------------------------------------
# environment

if [ `uname -o` = "Cygwin" ]; then
    export GIT_SSH=${HOMEPATH}\\Desktop\\gnupack\\putty-gdi-20130306\\plink.exe
fi

# time zone
export TZ=Asia/Tokyo

# history
# ignoreboth: ignore space and dups
export HISTCONTROL="ignoreboth"
export HISTFILESIZE="4096"
export HISTSIZE="4096"


# -------------------------------------------------------------
# terminal

# prompt
export PS1="\[${_PromptColor}\]
\[\e[0;37m\](\t)\[\e[00m\] [\u@\[\e[1;31m\]\H\[\e[00m\]:\w | Retv:\$? Jobs:\j]
# \[\e[0m\]"


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


