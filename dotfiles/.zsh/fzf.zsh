# ----------------------------------------------------------------------------------------------------
# aliasの設定
# ----------------------------------------------------------------------------------------------------

# vimのalias設定
if [ "$VIMTERMINAL" == "true" ]; then
    # vimのterminalモードからvimを実行するときはnvrで開く
    alias vim='nvr -c "call OpenFromTerminal()"'
else
    alias vim='nvim'
    alias vimf='nvim -c :VimFiler'
fi

# vimのファイラを開く
alias ff=vim .
# ファイル名で検索してディレクトリならそこへ移動し、ファイルならvimで開く
alias fa=find_and_cd_or_vim
# fgv  -- 文字列で検索してvimで開く
# fgv [query]  -- 文字列で検索してvimで開く
alias fgv=find_grep_and_vim

# fcv  -- キャッシュからファイルを探して、vimで開く
alias fcv=find_cache_and_vim

# ffv [filename]  -- [filename]をgrepして、そのマッチした行でvimを開く
# ffv [filename] [query]  -- [filename]を[query]でgrepして、そのマッチした行でvimを開く
alias ffv=find_grep_file_and_vim

# hs  -- ヒストリを検索するだけ
alias hs=show_history
# hr  -- ヒストリを検索してそのまま実行する
alias hr=run_history

# cdp  -- 親ディレクトリを検索して移動する
alias cdp=cd_to_parent_directory
# cdr  -- プロジェクトのルートディレクトリへ移動する
alias cdr=cd_project_root


# ----------------------------------------------------------------------------------------------------
# fzfの基本設定
# ----------------------------------------------------------------------------------------------------
if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
    PATH="${PATH:+${PATH}:}${HOME}/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${HOME}/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "${HOME}/.fzf/shell/key-bindings.zsh"
# ----------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------
# 検索周りの設定
# fzf, agを利用します
# ----------------------------------------------------------------------------------------------------

# tree表示して、fzfで絞り込んで、ディレクトリならcdで移動して、ファイルならvimで開く
find_and_cd_or_vim() {
    LBUFFER=""
    selected=$(tree --charset=o -f | fzf --query "$LBUFFER" --preview '
    f() {
        set -- $(echo -- "$@" | grep -o "\./.*$");
        if [ -d $1 ]; then
            ls -lh $1
        else
            head -n 100 $1
        fi
    }; f {}' | tr -d '\||`|-' | xargs echo)
    if [ "$selected" = "" ]; then
        return 0
    fi
    if [ -f $selected ]; then
        vim $selected
        return 0
    fi
    if [ -d $selected ]; then
        cd $selected
        ls
        return 0
    fi
}

# grep(ag)してvimで開く
find_grep_and_vim() {
  INITIAL_QUERY=""
  if [ $# != 0 ]; then
    INITIAL_QUERY=$1
  fi
  RG_PREFIX="ag "
  selected_file=$(FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
        fzf --bind "change:reload($RG_PREFIX {q} || true)" \
        --ansi --phony --query "$INITIAL_QUERY" \
        --preview 'cat `echo {} | cut -f 1 --delim ":"`')
  filename=$(echo $selected_file | awk -F ':' '{print $1}')
  linenum=$(echo $selected_file | awk -F ':' '{print $2}')
  option=""
  if [ "$linenum" != "" ]; then
    option="+${linenum}"
  fi
  vim $option $filename
}

# 特定ファイルに限定してgrep(ag & fzf)してvimで開く
find_grep_file_and_vim() {
    if [ $# < 1 ]; then
        echo "Usage: gfvim [filename] [query]"
        return 1
    fi
    FILENAME=$1
    INITIAL_QUERY=""
    if [ $# == 2 ]; then
      INITIAL_QUERY=$2
    fi
    RG_PREFIX="ag "
    selected=$(FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY' ${FILENAME}" \
    fzf --bind "change:reload($RG_PREFIX '{q}' ${FILENAME} || true)" \
          --ansi --phony --query "$INITIAL_QUERY" \
          --preview 'cat `echo {} | cut -f 1 --delim ":"`')
    linenum=$(echo $selected | awk -F ':' '{print $1}')
    vim +${linenum} ${FILENAME}
}

# grep_fzf(ag & fzf)するだけ
# grep_fzf [filename]  | 特定のファイル名から検索する
# grep_fzf  | 特定のファイル名から検索する
grep_fzf() {
  INITIAL_QUERY=""
  if [ $# == 0 ]; then
    RG_PREFIX="ag "
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
    fzf --bind "change:reload($RG_PREFIX {q} || true)" \
          --ansi --phony --query "$INITIAL_QUERY" \
          --preview 'cat `echo {} | cut -f 1 --delim ":"`'
  else
    FILENAME=$1
    RG_PREFIX="ag "
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY' ${FILENAME}" \
    fzf --bind "change:reload($RG_PREFIX '{q}' ${FILENAME} || true)" \
          --ansi --phony --query "$INITIAL_QUERY" \
          --preview 'cat `echo {} | cut -f 1 --delim ":"`'
  fi
}

cd_to_parent_directory() {
    local dirs=()
    local parent_dir

    get_parent_dirs() {
        if [[ -d "$1" ]]; then dirs+=("$1"); else return; fi
        if [[ "$1" == '/' ]]; then
            for _dir in "${dirs[@]}"; do echo "$_dir"; done
        else
            get_parent_dirs "$(dirname "$1")"
        fi
    }

    parent_dir="$(
      get_parent_dirs "$(realpath "${1:-$PWD}")" \
        | fzf +m \
            --preview 'ls {}' )" || return
    cd "$parent_dir" || return
    ls
}

show_history() {
    # fcの結果をuniqして、sortしなおす（直近実行したコマンドを下に出す）
    cmd=$((fc -l 1 || history) | sort -k 2 | uniq -f 1 | sort -n -k 1 | fzf +s | sed 's/ *[0-9]* *//')
    echo $cmd
}

run_history() {
    cmd=$((fc -l 1 || history) | sort -k 2 | uniq -f 1 | sort -n -k 1 | fzf +s | sed 's/ *[0-9]* *//')
    echo '$' $cmd
    eval $cmd
}

cd_project_root() {
    # gitがあればそこをprojetのrootとみなす
    result=`git rev-parse --show-toplevel 2> /dev/null`
    if [ $? == 0 ]; then
        cd $result
        return 0
    fi
}

find_cache_and_vim() {
    candidates=()
    buffers=(${(@s: :)VIM_BUFFERS})
    for buffer in "${buffers[@]}"; do
        if [ -e $buffer ]; then
            candidates+=($buffer)
        fi
    done

    oldfiles=$(nvim --headless -c 'oldfiles' -c 'q' 2>&1 > /dev/null)
    oldfiles=$(echo $oldfiles | awk -F ':' '{print $1": "$2}' | egrep -v 'term:|vimfiler|unite' | sort -k 2 | uniq -f 1 | sort -n -k 1 | awk '{print $2}' | sed -e 's/\r//g')
    for oldfile in `echo $oldfiles`; do
        if [ -e $oldfile ]; then
            candidates+=($oldfile)
        fi
    done
    candidates=$(IFS=$'\n'; echo "${candidates[*]}")
    selected=$(echo $candidates | fzf)
    if [ -f $selected ]; then
        vim $selected
    fi
}
