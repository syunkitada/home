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
# fzf, ripgrepを利用します
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

# grep(ripgrep & fzf)してvimで開く
gvim() {
  INITIAL_QUERY=""
  if [ $# != 0 ]; then
    INITIAL_QUERY=$1
  fi
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
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

# 特定ファイルに限定してgrep(ripgrep & fzf)してvimで開く
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
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    selected=$(FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY' ${FILENAME}" \
    fzf --bind "change:reload($RG_PREFIX '{q}' ${FILENAME} || true)" \
          --ansi --phony --query "$INITIAL_QUERY" \
          --preview 'cat `echo {} | cut -f 1 --delim ":"`')
    linenum=$(echo $selected | awk -F ':' '{print $1}')
    vim +${linenum} ${FILENAME}
}

# grep(ripgrep & fzf)するだけ
fgrep() {
  INITIAL_QUERY=""
  if [ $# == 0 ]; then
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
    fzf --bind "change:reload($RG_PREFIX {q} || true)" \
          --ansi --phony --query "$INITIAL_QUERY" \
          --preview 'cat `echo {} | cut -f 1 --delim ":"`'
  else
    FILENAME=$1
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
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

