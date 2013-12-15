if has('vim_starting')
   set nocompatible               " Be iMproved
   set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" Recommended to install
" After install, turn shell ~/.vim/bundle/vimproc, (n,g)make -f your_machines_makefile
NeoBundle 'Shougo/unite.vim'


" ----------------------------------------
" 各種設定
" ----------------------------------------
set fileformat=unix
set encoding=utf-8
set fileencodings=utf-8
set nocompatible " Vi互換モードOFF

syntax on
colorscheme molokai

" 日本語対応関連
set iminsert=0 " インサートモード中でデフォルト日本語入力をONにしない
set imsearch=0 " 検索モードでデフォルト日本語入力をONにしない
" C-] で日本語入力固定モード(デフォルト入力が日本語になる)の切替
inoremap <silent> <Esc> <Esc>
inoremap <silent> <C-[> <C-[>
inoremap <silent> <C-]> <C-^>

set number "行数の表示
" set relativenumber " 相対行番号を有効にする
set noswapfile
set nobackup
set virtualedit=block " 矩形ビジュアルモードの選択範囲をブロック型にする

" タブ（幅は4）
set tabstop=4
set shiftwidth=4

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


" -------------------------
" unite.vim
" -------------------------
" 入力モードで開始する
" let g:unite_enable_start_insert=1
" バッファ一覧
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
" ファイル一覧
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧
nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
" 最近使用したファイル一覧
nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
" 常用セット
nnoremap <silent> ,uu :<C-u>Unite buffer file_mru<CR>
" 全部乗せ
nnoremap <silent> ,ua :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>

" ファイル一覧時の動作
" qで終了
" Enterで現在のウィンドウに開く
" sでウィンドウを横に分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> s unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> s unite#do_action('split')
" vでウィンドウを縦に分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> v unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> v unite#do_action('vsplit')
" tでウィンドウをタブで開く
au FileType unite nnoremap <silent> <buffer> <expr> t unite#do_action('tabopen')
au FileType unite inoremap <silent> <buffer> <expr> t unite#do_action('tabopen')

" -------------------------
" YankRing.vim
" pでペーストした後に、Ctrl+p, Ctrl+nでそれ以前にヤンクした履歴をペーストできる
" -------------------------
let g:yankring_max_history = 10    " 記録する履歴の件数を10件に制限する
let g:yankring_window_height = 13  " 履歴全件を見通せるようにウィンドウの高さを調整

" -------------------------
" EasyMotion.vim
" Ctrl+m[移動コマンド]で移動可能先をハイライトしてアルファベットで移動先を指定できる
" -------------------------
let g:EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_leader_key = "<C-m>"
let g:EasyMotion_grouping = 1   " 1ストローク選択を優先する

" -------------------------
" tComment
" Alt+/ でコメントアウト
" -------------------------
map <silent> <A-/> :TComment<CR>


" -------------------------
" その他
" -------------------------
" -------------------------
" :Scouter でVimmerの戦闘力を計測
" -------------------------
function! Scouter(file, ...)
  let pat = '^\s*$\|^\s*"'
  let lines = readfile(a:file)
  if !a:0 || !a:1
    let lines = split(substitute(join(lines, "\n"), '\n\s*\\', '', 'g'), "\n")
  endif
  return len(filter(lines,'v:val !~ pat'))
endfunction
command! -bar -bang -nargs=? -complete=file Scouter
\        echo Scouter(empty(<q-args>) ? $MYVIMRC : expand(<q-args>), <bang>0)
command! -bar -bang -nargs=? -complete=file GScouter
\        echo Scouter(empty(<q-args>) ? $MYGVIMRC : expand(<q-args>), <bang>0)




 filetype plugin indent on     " Required!
 "
 " Brief help
 " :NeoBundleList          - list configured bundles
 " :NeoBundleInstall(!)    - install(update) bundles
 " :NeoBundleClean(!)      - confirm(or auto-approve) removal of unused bundles

 " Installation check.
 NeoBundleCheck
