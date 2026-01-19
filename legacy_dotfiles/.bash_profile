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

# SSH接続側で SSH Agent のソケットを管理する
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
    # SSHクライアント側で、SSH Agentのソケット管理
    # SSH Agentが起動している場合、そのソケットを自動検出してSSH_AUTH_SOCKに設定する
    # SSH agent socket auto-detect (newest one)
    newest_sock=""
    newest_mtime=0

    for sock in /tmp/*/agent.[0-9]*(N); do
        [ -S "$sock" ] || continue

        # GNU stat (Linux/WSL)
        mtime=$(stat -c %Y "$sock" 2>/dev/null) || continue

        if [ "$mtime" -gt "$newest_mtime" ]; then
        newest_mtime="$mtime"
        newest_sock="$sock"
        fi
    done

    if [ -n "$newest_sock" ]; then
        export SSH_AUTH_SOCK="$newest_sock"
    fi
fi

ssh_agent_start() {
    # すでに有効な agent があれば何もしない
    if [ -n "$SSH_AUTH_SOCK" ] && ssh-add -l >/dev/null 2>&1; then
        echo "Agent is already running."
        return 0
    fi
  
    local newest_sock=""
    local newest_mtime=0
    local sock mtime
  
    # 既存 agent の中から最新かつ有効なものを探す
    for sock in /tmp/*/agent.[0-9]*; do
        [ -S "$sock" ] || continue
  
        SSH_AUTH_SOCK="$sock" ssh-add -l >/dev/null 2>&1 || continue
  
        mtime=$(stat -c %Y "$sock" 2>/dev/null) || continue
        if [ "$mtime" -gt "$newest_mtime" ]; then
            newest_mtime="$mtime"
            newest_sock="$sock"
        fi
    done
  
    if [ -n "$newest_sock" ]; then
        export SSH_AUTH_SOCK="$newest_sock"
        return 0
    fi
  
    # 有効な agent がなければ新規起動
    eval "$(ssh-agent -s)" >/dev/null
    echo "Started a new SSH agent."
  
    # 鍵が未ロードなら追加（任意）
    if ! ssh-add -l >/dev/null 2>&1; then
        ssh-add </dev/null
    fi
}