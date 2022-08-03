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

# treeして、fzfして、ファイルならvimで開いて、ディレクトリならcdする
ff() {
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

# grep(ag & fzf)してvimで開く
gvim() {
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
gfvim() {
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

# grep(ag & fzf)するだけ
fgrep() {
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

# pd - cd to parent directory
pd() {
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

# fh - show history
fh() {
    # fcの結果をuniqして、sortしなおす（直近実行したコマンドを下に出す）
    cmd=$((fc -l 1 || history) | sort -k 2 | uniq -f 1 | sort -n -k 1 | fzf +s | sed 's/ *[0-9]* *//')
    echo $cmd
}

# fhr - show history and run
fhr() {
    cmd=$((fc -l 1 || history) | sort -k 2 | uniq -f 1 | sort -n -k 1 | fzf +s | sed 's/ *[0-9]* *//')
    echo '$' $cmd
    eval $cmd
}

# projectのrootへ移動する
cdpjroot() {
    # gitがあればそこをprojetのrootとみなす
    result=`git rev-parse --show-toplevel 2> /dev/null`
    if [ $? == 0 ]; then
        cd $result
        return 0
    fi
}

# キャッシュからファイルを選択してvimで開く
cvim() {
    candidates=()
    buffers=(${(@s: :)VIM_BUFFERS})
    for buffer in "${buffers[@]}"; do
        if [ -e $buffer ]; then
            candidates+=($buffer)
        fi
    done

    oldfiles=$(vim --headless -c 'oldfiles' -c 'q' 2>&1 > /dev/null)
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
