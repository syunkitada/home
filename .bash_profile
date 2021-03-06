# -------------------------------------------------------------
# environment


# zshがあるならzshを使う
[ -x "/bin/zsh" ] && exec /bin/zsh


# for cygwin on windows
if [[ `uname` =~ ^CYGWIN ]]; then
    plink="$HOME/Desktop/cygwin/putty/plink"
    plink_exe=${plink/$HOME/$HOMEPATH}.exe
    plink_exe=${plink_exe//\//\\}
    alias exp='explorer .'
    alias plink="${plink} -ssh -A -l `whoami`"
    export GIT_SSH=$plink_exe

    # start sshagent
    # if add ssh agent, run $ ssh-add [id_rsa]
    SSHAGNET=/usr/bin/ssh-agent
    SSHAGENT=/usr/bin/ssh-agent
    SSHAGENTARGS="-s"
    if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT" ]; then
        eval `$SSHAGENT $SSHAGENTARGS`
        trap "kill $SSH_AGENT_PID" 0
    fi

else
    # ForwardAgent が有効な状態で、ssh ログインしなおすと、環境変数SSH_AUTH_SOCK が新しいパスをさすようになる
    # ここで tmux attach すると、tmux セッション上のシェルは以前の SSH_AUTH_SOCK の値を保持し続けていてるので認証ができなくなる
    # このため、ログインするたびに $HOME/.ssh/agent に symlink を貼るようにする
    agent="$HOME/.ssh/agent"
    if [ -S "$SSH_AUTH_SOCK" ]; then
        case $SSH_AUTH_SOCK in
        /tmp/*/agent.[0-9]*)
            ln -snf "$SSH_AUTH_SOCK" $agent && export SSH_AUTH_SOCK=$agent
        esac
    elif [ -S $agent ]; then
        export SSH_AUTH_SOCK=$agent
    else
        echo "no ssh-agent"
    fi
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

# change path priorities
export PATH=$HOME/.local/bin:$PATH

if [ -e /usr/bin/virtualenvwrapper.sh ]; then
    export WORKON_HOME=$HOME/.virtualenvs
    export PROJECT_HOME=$HOME/Devel
    source `which virtualenvwrapper.sh`
fi


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

# arias for screen and tmux
alias s='screen'
alias sa='screen -r'
alias sl='screen -ls'
alias t='tmux'
alias ta='tmux a'
alias tl='tmux ls'


# -------------------------------------------------------------
# end .bash_profile
#
# if you want to add your settings, please describe below.
# -------------------------------------------------------------

