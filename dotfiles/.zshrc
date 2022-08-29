# ------------------------------
# General Settings
# ------------------------------
export EDITOR=nvim        # エディタをvimに設定
export VISUAL=nvim        # lessから使うエディタをvimに設定
export LANG=ja_JP.UTF-8  # 文字コードをUTF-8に設定
export KCODE=u           # KCODEにUTF-8を設定
export TZ=Asia/Tokyo
# export TERM='xterm-256color'
export PATH=$HOME/.local/bin:$PATH
export XDG_CONFIG_HOME=$HOME/.config


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


bindkey -e # キーバインドをemacsモードに設定
# bindkey -v # キーバインドをviモードに設定

setopt no_beep           # ビープ音を鳴らさないようにする
setopt auto_cd           # ディレクトリ名の入力のみで移動する 
setopt auto_pushd        # cd時にディレクトリスタックにpushdする
setopt correct           # コマンドのスペルを訂正する
setopt magic_equal_subst # =以降も補完する(--prefix=/usrなど)
setopt prompt_subst      # プロンプト定義内で変数置換やコマンド置換を扱う
setopt notify            # バックグラウンドジョブの状態変化を即時報告する
setopt equals            # =commandを`which command`と同じ処理にする
setopt nonomatch         # no matches foundを無効にする(これがあるとメタ文字が使えない)


### Complement ###
autoload -U compinit; compinit # 補完機能を有効にする
setopt auto_list               # 補完候補を一覧で表示する(d)
setopt auto_menu               # 補完キー連打で補完候補を順に表示する(d)
setopt list_packed             # 補完候補をできるだけ詰めて表示する
setopt list_types              # 補完候補にファイルの種類も表示する
bindkey "^[[Z" reverse-menu-complete  # Shift-Tabで補完候補を逆順する("\e[Z"でも動作する)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # 補完時に大文字小文字を区別しない

### Glob ###
setopt extended_glob # グロブ機能を拡張する
unsetopt caseglob    # ファイルグロブで大文字小文字を区別しない


### History ###
HISTFILE=~/.zsh_history   # ヒストリを保存するファイル
HISTSIZE=10000            # メモリに保存されるヒストリの件数
SAVEHIST=10000            # 保存されるヒストリの件数
setopt bang_hist          # !を使ったヒストリ展開を行う(d)
setopt extended_history   # ヒストリに実行時間も保存する
setopt hist_ignore_dups   # 直前と同じコマンドはヒストリに追加しない
setopt hist_reduce_blanks # 余分なスペースを削除してヒストリに保存する
# setopt share_history      # 他のシェルのヒストリをリアルタイムで共有する

# マッチしたコマンドのヒストリを表示できるようにする
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^N" history-beginning-search-backward-end
bindkey "^P" history-beginning-search-forward-end

# すべてのヒストリを表示する
function history-all { history -E 1 }


# ------------------------------
# Look And Feel Settings
# ------------------------------
# 色を付ける
autoload -U colors; colors

### Ls Color ###
# 色の設定
export LSCOLORS=ExFxCxdxBxegedabagacad

# 補完時の色の設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
# ZLS_COLORSとは？
export ZLS_COLORS=$LS_COLORS
# lsコマンド時、自動で色がつく(ls -Gのようなもの？)
export CLICOLOR=true
# 補完候補に色を付ける
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# 色を定義
local GREEN=$'%{\e[1;32m%}'
local BLUE=$'%{\e[1;34m%}'
local DEFAULT=$'%{\e[1;m%}'


# cdコマンド実行後、lsを実行する
#function cd() {
#  builtin cd $@ && ls;
#}


### Prompt ###
tmp_prompt="
%{${fg[cyan]}%}%T [%?] %n@%M:%~%{${reset_color}%}
\$ "
tmp_prompt2="%{${fg[cyan]}%}%_> %{${reset_color}%}"
tmp_sprompt="%{${fg[yellow]}%}%r is correct? [Yes, No, Abort, Edit]:%{${reset_color}%}"

PROMPT=$tmp_prompt    # 通常のプロンプト
PROMPT2=$tmp_prompt2  # セカンダリのプロンプト(コマンドが2行以上の時に表示される)
SPROMPT=$tmp_sprompt  # スペル訂正用プロンプト

# rpromptにgitのリポジトリ情報を表示
# vcs_infoは遅いので使わない
function rprompt-git-current-branch {
    local name st color symbol
    if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
        return
    fi
    name=$(basename "`git symbolic-ref HEAD 2> /dev/null`")
    if [[ -z $name ]]; then
        return
    fi
    st=`git status 2> /dev/null`
    if [[ -n `echo "$st" | grep "nothing to"` ]]; then
        color=%F{green}
        symbol=''
    else
        symbol=' '
        color=%F{yellow}
        if [[ -n `echo "$st" | grep "Unmerged paths"` ]]; then
            color=%F{red}
            symbol=$symbol'*+|MERGING'
        else
            if [[ -n `echo "$st" | grep "Untracked"` ]]; then
                symbol=$symbol'?'
            fi
            if [[ -n `echo "$st" | grep "Changes to be committed"` ]]; then
                symbol=$symbol'+'
            fi
            if [[ -n `echo "$st" | grep "Changed but not updated"` ]]; then
                symbol=$symbol'*'
            elif [[ -n `echo "$st" | grep "Changes not staged for commit"` ]]; then
                symbol=$symbol'*'
            fi
        fi
    fi
    echo "$color%\[$name$symbol%\]%f%b"
}

RPROMPT='`rprompt-git-current-branch`'
setopt transient_rprompt  # コピペしやすいようにコマンド実行後は右プロンプトを消す


contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

# load common scripts
for file in `find ~/.zsh/ -name '*.zsh' -type f | sort`
do
    source $file
done

# .zsh_mydevは、特定ユーザ(個人開発)の場合のみロードする
if echo $USER | egrep "owner|tester" > /dev/null; then
    source ~/.zsh_mydev/*.zsh
    for file in `find ~/.zsh_mydev/ -name '*.zsh' -type f | sort`
    do
        source $file
    done
fi

# .zsh_exは、拡張用のスクリプト置き場
for file in `find ~/.zsh_ex/ -name '*.zsh' -type f | sort`
do
    source $file
done
