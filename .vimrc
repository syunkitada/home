" vim_startingは、vimの起動時のみ真になる
if has('vim_starting')
	set nocompatible               " Be iMproved
	set runtimepath+=~/.vim/bundle/neobundle.vim/

	" autoload my vimscript
	runtime! userautoload/*.vim
endif

" neobundleの初期化
call neobundle#rc(expand('~/.vim/bundle/'))

" plugins
NeoBundle 'git://github.com/Shougo/unite.vim'
NeoBundle 'git://github.com/Shougo/vimfiler.vim'
NeoBundle 'git://github.com/Shougo/neocomplcache'
NeoBundle 'git://github.com/Shougo/vimshell'
NeoBundle 'git://github.com/Shougo/vimproc', {
      \ 'build' : {
      \     'windows' : 'make -f make_mingw32.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }
NeoBundle 'git://github.com/Sim-scripts/YankRing.vim'
NeoBundle 'git://github.com/Sim-scripts/tComment'
NeoBundle 'git://github.com/Sim-scripts/sudo.vim'
NeoBundle 'git://github.com/Sokaltog/vim-easymotion'
NeoBundle 'git://github.com/Soldfeld/vim-seek'
NeoBundle 'git://github.com/thinca/vim-quickrun'
NeoBundle 'git://github.com/gregsexton/gitv.git'
NeoBundle 'git://github.com/mhinz/vim-startify.git'
NeoBundle 'git://github.com/mattn/emmet-vim.git'
NeoBundle 'git://github.com/tpope/vim-surround.git'
NeoBundle 'git://github.com/tpope/vim-fugitive.git'

" ----------------------------------------
" 各種設定
" ----------------------------------------
set fileformat=unix
set encoding=utf-8
set fileencodings=utf-8
set nocompatible

" マウス操作を有効にする
set mouse=nv

" シンタックス
syntax on
colorscheme molokai

" 日本語対応関連
set iminsert=0 " インサートモード中でデフォルト日本語入力をONにしない
set imsearch=0 " 検索モードでデフォルト日本語入力をONにしない

set number "行数の表示
" set relativenumber " 相対行番号を有効にする
set noswapfile
set nobackup
set virtualedit=block " 矩形ビジュアルモードの選択範囲をブロック型にする

" タブ（幅は4）
set autoindent
set tabstop=4
set shiftwidth=4
" タブをスペースにする
" set expandtab

" 検索設定 
set hlsearch
set incsearch
set ignorecase

"コマンドラインモードにおける補完機能を設定
"list:full は、候補が2つ以上あるときに、すべての候補を一覧表示にし、最初に並ぶ候補を補完対象とする
set wildmenu wildmode=list:full 

" Backspaceで文字を消せるようにする
" startは、ノーマルモードに移った後に、再び挿入モードに入った時に削除可能にする
" eolは、行頭でBackspaceを押した時に行を連結できるようにする
" indentは、オートインデントモードのインデントを削除可能にする
set backspace=start,eol,indent

" set vim title
let &t_ti .= "\e[22;0t"
let &t_te .= "\e[23;0t"
set title

" ---------- NeoBundle ----------
filetype plugin indent on " Required!
"
" Brief help
" :NeoBundleList          - list configured bundles
" :NeoBundleInstall(!)    - install(update) bundles
" :NeoBundleClean(!)      - confirm(or auto-approve) removal of unused bundles

" Installation check.
NeoBundleCheck


