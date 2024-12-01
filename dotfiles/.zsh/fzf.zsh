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
# [COMMAND] key=ff; tags=find; action=vimでファイラを開きます;
alias fv=vim .
# [COMMAND] key=fa; tags=find; action=ファイル名で検索してディレクトリならそこへ移動し、ファイルならvimで開きます;
alias ff=find_file_and_vim
# [COMMAND] key=fgv [query:option]; tags=find; action=文字列で(queryがあればqueryで)ファイルを検索して、vimで開きます;
alias ft=find_text_and_vim

# [COMMAND] key=fh; tags=find; action=ヒストリからファイルを検索してvimで開きます;
alias fh=find_history_and_vim

# [COMMAND] key=ftt [filename] [query:option]; tags=find; action=[filename]を([query]があればqueryで)grepして、そのマッチした行をvimで開きます;
alias ftt=find_text_target_and_vim

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

# ----------------------------------------------------------------------------------------------------
# 検索周りの設定
# fzf, agを利用します
# ----------------------------------------------------------------------------------------------------

# ファイル名を検索してvimで開く
function find_file_and_vim() {
	LBUFFER="$1"
	PREVIEW='
f() {
    set -- $(echo -- "$@" | grep -o "\./.*$");
    if [ -d $1 ]; then
        ls -lh $1
    else
        head -n 100 $1
    fi
}; f {}'
	selected=$(tree --charset=o -f |
		fzf --query "$LBUFFER" \
			--delimiter=":" \
			--preview ${PREVIEW} |
		tr -d '\||`|-' | xargs echo)
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

# ファイル内のtestを検索して、そのファイルをvimで開く
function find_text_and_vim() {
	INITIAL_QUERY=""
	if [ $# != 0 ]; then
		INITIAL_QUERY=$1
	fi
	RG_PREFIX="ag "
	PREVIEW="sed -n {2},+4p {1} | grep --color=always -A 5 -- {-1}"
	selected_file=$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
			fzf --bind "change:reload($RG_PREFIX {q} || true)" \
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

# batcatによるpreview表示はリッチではあるが、少し遅いのと、検索文字列のハイライトがわかりずらいので廃止しました
function find_text_and_vim_deprecated() {
	INITIAL_QUERY=""
	if [ $# != 0 ]; then
		INITIAL_QUERY=$1
	fi
	RG_PREFIX="ag "
	PREVIEW='batcat --color=always --theme="Nord" {1} --highlight-line {2}'
	if ! which batcat >/dev/null; then
		PREVIEW='cat {1}'
	fi
	selected_file=$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
			fzf --bind "change:reload($RG_PREFIX {q} || true)" \
			--multi \
			--query "$INITIAL_QUERY" \
			--delimiter=":" \
			--preview-window=+{2}+3/2,~3 \
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

# 特定ファイルに限定して、ftを実行する
function find_text_target_and_vim() {
	if [ $# ] <1; then
		echo "Usage: gfvim [filename] [query]"
		return 1
	fi
	FILENAME=$1
	INITIAL_QUERY=""
	if [ $# == 2 ]; then
		INITIAL_QUERY=$2
	fi
	RG_PREFIX="ag "
	PREVIEW='batcat --color=always --theme="Nord" '$FILENAME' --highlight-line {1}'
	if ! which batcat >/dev/null; then
		PREVIEW='cat {1}'
	fi
	selected_file=$(FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY' ${FILENAME}" \
		fzf --bind "change:reload($RG_PREFIX {q} ${FILENAME} || true)" \
		--query "$INITIAL_QUERY" \
		--delimiter=":" \
		--preview-window=+{1}+3/2,~3 \
		--preview=$PREVIEW)

	linenum=$(echo $selected_file | awk -F ':' '{print $1}')
	option=""
	if [ "$linenum" != "" ]; then
		option="+${linenum}"
	fi
	vim $option $FILENAME
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

# grep_fzf(ag & fzf)するだけ
# grep_fzf [filename]  | 特定のファイル名から検索する
# grep_fzf  | 特定のファイル名から検索する
function grep_fzf() {
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
	candidates=()
	for buffer in $(echo ${VIM_BUFFERS}); do
		if [ -e $buffer ]; then
			candidates+=($buffer)
		fi
	done

	oldfiles=$(nvim --headless -c 'oldfiles' -c 'q' 2>&1 >/dev/null)
	oldfiles=$(echo $oldfiles | awk -F ':' '{print $1": "$2}' | egrep -v 'term:|vimfiler|unite' | sort -k 2 | uniq -f 1 | sort -n -k 1 | awk '{print $2}' | sed -e 's/\r//g')
	for oldfile in $(echo $oldfiles); do
		if [ -e $oldfile ]; then
			candidates+=($oldfile)
		fi
	done
	candidates=$(
		IFS=$'\n'
		echo "${candidates[*]}"
	)
	selected=$(echo $candidates | fzf)
	if [ -f $selected ]; then
		vim $selected
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
