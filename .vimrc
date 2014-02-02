" vim_startingは、vimの起動時のみ真になる
if has('vim_starting')
	set nocompatible               " Be iMproved
	set runtimepath+=~/.vim/bundle/neobundle.vim/
	set runtimepath+=~/.vim/
	runtime! userautoload/*.vim
endif

let &t_ti .= "\e[22;0t"
let &t_te .= "\e[23;0t"
set title

" neobundleの初期化
call neobundle#rc(expand('~/.vim/bundle/'))

" Recommended to install
" After install, turn shell ~/.vim/bundle/vimproc, (n,g)make -f your_machines_makefile
" :NeoBundleInstall
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/vimproc', {
      \ 'build' : {
      \     'windows' : 'make -f make_mingw32.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }
NeoBundle 'vim-scripts/YankRing.vim'
NeoBundle 'vim-scripts/tComment'
NeoBundle 'vim-scripts/sudo.vim'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'goldfeld/vim-seek'
NeoBundle 'mattn/emmet-vim'


" ----------------------------------------
" 各種設定
" ----------------------------------------
set fileformat=unix
set encoding=utf-8
set fileencodings=utf-8
set nocompatible

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

" タブ（幅は4）, タブをスペースにする
set autoindent
set tabstop=4
set shiftwidth=4
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


" ----------------------------------------
" .vimrc
" ----------------------------------------
" .vimrcのオープンコマンド
let vimrcbody = '$MYVIMRC'
let gvimrcbody = '$MYGVIMRC'
function! OpenFile(file)
    let empty_buffer = line('$') == 1 && strlen(getline('1')) == 0
    if empty_buffer && !&modified
        execute 'e ' . a:file
    else
        execute 'tabnew ' . a:file
    endif
endfunction
command! OpenMyVimrc call OpenFile(vimrcbody)
command! OpenMyGVimrc call OpenFile(gvimrcbody)
nnoremap <Space><Space> :<C-u>OpenMyVimrc<CR>
nnoremap <Space><Tab> :<C-u>OpenMyGVimrc<CR>

" .vimrcを編集したら即反映する
augroup MyAutoCmd
    autocmd!
augroup END

if !has('gui_running') && !(has('win32') || has('win64'))
    " .vimrcの再読込時にも色が変化するようにする
    autocmd MyAutoCmd BufWritePost $MYVIMRC nested source $MYVIMRC
else
    " .vimrcの再読込時にも色が変化するようにする
    autocmd MyAutoCmd BufWritePost $MYVIMRC source $MYVIMRC | 
                \if has('gui_running') | source $MYGVIMRC  
    autocmd MyAutoCmd BufWritePost $MYGVIMRC if has('gui_running') | source $MYGVIMRC
endif


" コンパイルして実行
augroup MyGroup
    autocmd Filetype c command! Compile call CCompile()
    autocmd Filetype cpp command! Compile call CppCompile()
    autocmd Filetype python command! Compile call PyCompile()
    autocmd Filetype perl command! Compile call PlCompile()
augroup END
function! CCompile()
    echo compile
endfunction
function! CppCompile()
    echo compile
endfunction
function! PyCompile()
    :w
    :!python %
endfunction
function! PlCompile()
    :w
    :!perl %
endfunction

map ,c :Compile<CR>






filetype plugin indent on     " Required!
"
" Brief help
" :NeoBundleList          - list configured bundles
" :NeoBundleInstall(!)    - install(update) bundles
" :NeoBundleClean(!)      - confirm(or auto-approve) removal of unused bundles

" Installation check.
NeoBundleCheck

