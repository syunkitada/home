#
# tmux helpers
#
function _tmux_new_cmd() {
    tmux new-window "bash --rcfile <(echo '$*')"
}

function _tmux_split_cmd() {
    tmux split-window "bash --rcfile <(echo '$*')"
}

function tx() {
    for i in {2..$1}
    do
        tmux split-window "zsh"
    done
    tmux select-layout tiled
}

#
# ssh, scp helpers
#
function mssh() {
    if [ $# != 1 ]; then
        echo "Usage: mssh [file]"
        return 1
    fi
    _mssh `cat $1`
}

function _mssh() {
    # 1つ目のホストに新しいwindowでsshする
    tmux new-window "ssh $1"
    # 2つ目以降のホストにsshする
    shift
    for host in "$@";
    do
        tmux split-window "ssh $host"
        # tmux select-layout even-vertical > /dev/null
        tmux select-layout even-horizontal > /dev/null
    done
    tmux set-window-option synchronize-panes on
    tmux select-layout tiled
}


function cssh() {
    if [ $# != 1 ]; then
        echo "Usage: cssh [file] [command...]"
        return 1
    fi

    file=$1
    shift
    for host in `cat $file`;
    do
        result=`ssh $host "$@"`
        echo "${host}[$?] $result"
    done
}


function scphome() {
    if [ $# != 1 ]; then
        echo "Usage: scphome [target]"
        return 1
    fi

    set -x
    tar -czf repos.tar.gz .cache/neovim-dein
    tar -czf home.tar.gz home
    tar -czf localsharenvim.tar.gz .local/share/nvim
    scp repos.tar.gz $1:
    scp home.tar.gz $1:
    scp localsharenvim.tar.gz $1:
    ssh $1 rm -rf ~/home
    ssh $1 rm -rf ~/.cache
    ssh $1 rm -rf ~/.local
    ssh $1 tar -xf ~/repos.tar.gz -C ~/
    ssh $1 tar -xf ~/home.tar.gz -C ~/
    ssh $1 tar -xf ~/localsharenvim.tar.gz -C ~/
    ssh $1 rm -rf ~/repos.tar.gz
    ssh $1 rm -rf ~/home.tar.gz

    ssh  $1 rm -rf .local/share/nvim

    rm -rf repos.tar.gz
    rm -rf home.tar.gz
    set +x
}


#
# network helpers
#
function mping() {
    if [ $# != 1 ]; then
        echo "Usage: mping [file]"
        return 1
    fi

    _mping `cat $1`
}

function _mping() {
    _tmux_new_cmd 'while true; do echo "`date +\"%H:%M:%S\"` `ping '$1' -c 1 -w 1 -W 1 | sed -n 2P`"; sleep 1s; done'
    shift
    for host in "$@";
    do
        _tmux_split_cmd 'while true; do echo "`date +\"%H:%M:%S\"` `ping '$host' -c 1 -w 1 -W 1 | sed -n 2P`"; sleep 1s; done'
        tmux select-layout even-horizontal > /dev/null
    done
    tmux set-window-option synchronize-panes on
    tmux select-layout tiled
}

function wping() {
    if [ $# != 1 ]; then
        echo "Usage: wping [target]"
        return 1
    fi

    while true; do echo "`date +"%H:%M:%S"` `ping $1 -c 1 -w 1 -W 1 | sed -n 2P`"; sleep 1s; done
}

function wcurl() {
    if [ $# != 1 ]; then
        echo "Usage: wcurl [target]"
        return 1
    fi

    while true; do echo "`date +"%H:%M:%S"` $1 `curl $1 --connect-timeout 1 -s -o /dev/null -w 'time=%{time_starttransfer}s code=%{http_code}\n' -s`"; sleep 1s; done
}

function wdig() {
    if [ $# != 1 ]; then
        echo "Usage: wdig [target]"
        return 1
    fi

    while true; do echo "`date +"%H:%M:%S"` $1 `\time -f '%e' -- dig +short $1 2>&1 | sed -r -e ':loop;N;$!b loop;s/\n/ time=/g'`"; sleep 1s; done
}


#
# fzf helpers
#
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fe - edit
fe() {
  local file
  file=$(fzf --query="$1" --select-1 --exit-0)
  [ -n "$file" ] && ${EDITOR:-vim} "$file"
}

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-*} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fh - repeat history
fh() {
  eval $(([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s | sed 's/ *[0-9]* *//')
}
