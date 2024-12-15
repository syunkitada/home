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

# [COMMAND] key=ff; tags=find; action=ファイル名で検索してディレクトリならそこへ移動し、ファイルならvimで開きます;
alias ff=find_file_and_vim
# [COMMAND] key=fd; tags=find; action=ディレクトリ名で検索してそこへ移動します;
alias fd=find_directory_and_cd
# [COMMAND] key=ft; tags=find; action=文字列で(queryがあればqueryで)ファイルを検索して、vimで開きます;
alias ft=find_text_and_vim
# [COMMAND] key=fh; tags=find; action=ヒストリからファイルを検索してvimで開きます;
alias fh=find_history_and_vim

# [COMMAND] key=cdp; tags=move; action=親ディレクトリを検索して移動します;
alias cdp=cd_to_parent_directory
# [COMMAND] key=cdr; tags=move; action=プロジェクトのルートディレクトリへ移動する;
alias cdr=cd_project_root

# ----------------------------------------------------------------------------------------------------
# fzfの基本設定
# ----------------------------------------------------------------------------------------------------
# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${HOME}/.fzf/shell/completion.zsh" 2>/dev/null

# Key bindings
# ------------
source "${HOME}/.fzf/shell/key-bindings.zsh"
# ----------------------------------------------------------------------------------------------------

# Reference: https://github.com/junegunn/fzf/blob/8a5f7199649d56a92474676c9cf626204e3e8bcb/ADVANCED.md#color-themes
FZF_COLOR='--color=bg+:#293739,bg:#1B1D1E,border:#808080,spinner:#E6DB74,hl:#7E8E91,fg:#F8F8F2,header:#7E8E91,info:#A6E22E,pointer:#A6E22E,marker:#F92672,fg+:#F8F8F2,prompt:#F92672,hl+:#F92672'
# FZF_COLOR='--color=bg+:#3F3F3F,bg:#4B4B4B,border:#6B6B6B,spinner:#98BC99,hl:#719872,fg:#D9D9D9,header:#719872,info:#BDBB72,pointer:#E12672,marker:#E17899,fg+:#D9D9D9,preview-bg:#3F3F3F,prompt:#98BEDE,hl+:#98BC99'
# fzfのデフォルトの検索は、あいまい検索（検索文字列の一部が一致するとヒットする）であるため不用意に大量のファイルが見つかってしまうため、--exact オプションにより無効にする
export FZF_DEFAULT_OPTS="--exact ${FZF_COLOR}"

FZF_TREE_IGNORE=".git|.venv|.*cache|__pycache__"

# ----------------------------------------------------------------------------------------------------
# 検索周りの設定
# fzf, agを利用します
# ----------------------------------------------------------------------------------------------------

# ファイル名を検索してvimで開く
function find_file_and_vim() {
	INITIAL_QUERY="$1"

	PREVIEW='
f() {
    set -- $(echo -- "$@" | grep -o "\./.*$");
    if [ -d $1 ]; then
        ls -lh $1
    else
        head -n 100 $1
    fi
}; f {}'

	files=$(tree --noreport --charset=o -af -I ${FZF_TREE_IGNORE} | sed -e '1d')
	selected=$(echo $files |
		fzf --reverse --query "$INITIAL_QUERY" \
			--preview ${PREVIEW} |
		sed -e 's/.*[|`]-- //g')

	if [ "$selected" = "" ]; then
		return 0
	fi
	if [ -f $selected ]; then
		vim $selected
		return 0
	fi
	if [ -d $selected ]; then
		vim $selected
		return 0
	fi
}

# ディレクトリ名を検索して移動する
function find_directory_and_cd() {
	INITIAL_QUERY=""
	if [ $# != 0 ]; then
		INITIAL_QUERY=$1
	fi

	PREVIEW='
f() {
    path="${@}"
    if [ "${path:0:1}" != "/" ]; then
        set -- $(echo -- "$@" | grep -o "\./.*$");
    fi
    ls -lh $1
}; f {}'

	directories=$(tree --charset=o -af -d --noreport -I ${FZF_TREE_IGNORE} | sed -e '1d')

	local dirs=()
	get_parent_dirs() {
		if [[ -d "$1" ]]; then dirs+=("$1"); else return; fi
		if [[ "$1" == '/' ]]; then
			for _dir in "${dirs[@]}"; do echo "$_dir"; done
		else
			get_parent_dirs "$(dirname "$1")"
		fi
	}
	parent_dirs=$(get_parent_dirs "$(realpath "${1:-$PWD}")")

	directories="${parent_dirs}\n${directories}"

	selected=$(echo $directories |
		fzf --reverse --query "$INITIAL_QUERY" \
			--preview ${PREVIEW} |
		sed -e 's/.*[|`]-- //g')

	if [ "$selected" = "" ]; then
		return 0
	fi
	cd $selected
	ls
}

# ファイル内のtestを検索して、そのファイルをvimで開く
function find_text_and_vim() {
	INITIAL_QUERY=""
	if [ $# -gt 0 ]; then
		INITIAL_QUERY=$1
	fi

	TARGET_FILE=""
	if [ $# -gt 1 ]; then
		TARGET_FILE=$2
	fi

	PREVIEW='
f() {
    query={q}
    if [ "$@" == "" ]; then
        echo "No match query: ${query}"
        return
    fi

    linenum=${2}
    linenum=$((linenum-1))
    if [ ${linenum} -eq 0 ]; then
        linenum=1
    fi

    if [ "${query}" = "" ]; then
        sed -n ${linenum},+4p ${1} | grep -i --color=always -B 1 -A 4 -- ${-1}
    else
	    sed -n ${linenum},+4p ${1} | grep -i --color=always -B 1 -A 4 -- ${query}
    fi
}; f {}'

	# --preview-window=down,5 :文字列検索の場合、検索結果が横長となるのでpreviewは下に表示します
	# --ansi :PREVIEW画面で、grepのansiカラー表示を有効化するために必要です
	GREP_CMD="grep -ir --line-number"
	selected_file=$(
		FZF_DEFAULT_COMMAND="$GREP_CMD '$INITIAL_QUERY' $TARGET_FILE" \
			fzf --bind "change:reload($GREP_CMD {q} $TARGET_FILE || true)" \
			--query "$INITIAL_QUERY" \
			--delimiter=":" \
			--ansi \
			--preview-window=down,5 \
			--preview=$PREVIEW
	)

	filename=$(echo $selected_file | awk -F ':' '{print $1}')
	if [ "$filename" == "" ]; then
		return 0
	fi
	linenum=$(echo $selected_file | awk -F ':' '{print $2}')
	option=""
	if [ "$linenum" != "" ]; then
		option="+${linenum}"
	fi
	vim $option $filename
}

# [DOC]をgrep(ag)してvimで開く
function find_grep_doc_and_vim() {
	INITIAL_QUERY=""
	if [ $# != 0 ]; then
		INITIAL_QUERY=$1
	fi
	RG_PREFIX="ag"
	selected_file=$(FZF_DEFAULT_COMMAND="$RG_PREFIX '\[DOC]' | sed -e 's/:.*\[.*] /:/g'" \
		fzf --bind "change:reload($RG_PREFIX '\[DOC]' | ($RG_PREFIX {q} || cat) | sed -e 's/:.*\[.*] /:/g')" \
		--ansi --phony --query "$INITIAL_QUERY" \
		--preview 'cat `echo {} | cut -f 1 --delim ":"`')
	filename=$(echo $selected_file | awk -F ':' '{print $1}')
	if [ "$filename" == "" ]; then
		return 0
	fi
	vim $filename
}

function cd_to_parent_directory() {
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
		get_parent_dirs "$(realpath "${1:-$PWD}")" |
			fzf +m \
				--preview 'ls {}'
	)" || return
	cd "$parent_dir" || return
	ls
}

function cd_project_root() {
	# gitがあればそこをprojetのrootとみなす
	result=$(git rev-parse --show-toplevel 2>/dev/null)
	if [ $? == 0 ]; then
		cd $result
		return 0
	fi
}

function find_history_and_vim() {
	INITIAL_QUERY=""
	if [ $# != 0 ]; then
		INITIAL_QUERY=$1
	fi

	oldfiles=$(nvim --headless -c 'oldfiles' -c 'q' 2>&1 >/dev/null)
	oldfiles=$(echo $oldfiles | awk -F ':' '{print $1": "$2}' | egrep -v 'term:' | sort -k 2 | uniq -f 1 | sort -n -k 1 | awk '{print $2}' | sed -e 's/\r//g')
	candidates=()
	for oldfile in $(echo $oldfiles); do
		if [ -e $oldfile ]; then
			candidates+=($oldfile)
		fi
	done

	candidates=$(
		IFS=$'\n'
		echo "${candidates[*]}"
	)

	PREVIEW='head -n 100 {}'

	selected=$(echo $candidates |
		fzf --query "$INITIAL_QUERY" \
			--preview ${PREVIEW})

	if [ "$selected" = "" ]; then
		return 0
	fi
	if [ -f $selected ]; then
		vim $selected
		return 0
	fi
	if [ -d $selected ]; then
		vim $selected
		return 0
	fi
}

# ドキュメントの検索
# [COMMAND] key=doccmd; tags=doc; action=コマンドのドキュメントを検索します
# [COMMAND] key=doccmdg; tags=doc; action=コマンドのドキュメントを検索します
alias doccmd="cd ~/home/docs_cmd && find_grep_doc_and_vim"
alias doccmdg="cd ~/home/docs_cmd && find_file_and_vim"
# [COMMAND] key=docops; tags=doc; action=コマンドのドキュメントを検索します
# [COMMAND] key=docopsg; tags=doc; action=コマンドのドキュメントを検索します
alias docops="cd ~/home/docs_ops && find_grep_doc_and_vim"
alias docopsg="cd ~/home/docs_ops && find_file_and_vim"

# キーバインドの検索
# [COMMAND] key=dockey; tags=doc; action=キーバインドのドキュメントを検索します
alias dockey="cd ~/home/docs_env/keybind/ && find_file_and_vim"
# [COMMAND] key=dockeydefault; tags=doc; action=ノーマルモードのドキュメントを表示します
alias dockeydefault='vim ~/home/docs_env/keybind/default.txt'
# [COMMAND] key=dockeyzsh; tags=doc; action=zshのコマンドのドキュメントを表示します
alias dockeyzsh='vim ~/home/docs_env/keybind/zsh.txt'
# [COMMAND] key=dockeyvim; tags=doc; action=vimノーマルモードのドキュメントを表示します
alias dockeyvim='vim ~/home/docs_env/keybind/vim.txt'
# [COMMAND] key=dockeytmux; tags=doc; action=tmuxのドキュメントを表示します
alias dockeytmux='vim ~/home/docs_env/keybind/tmux.txt'
