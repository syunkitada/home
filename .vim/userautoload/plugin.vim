"
" -------------------------
"  vimfiler
"
" # 使い方
" -- 表示 --
" t   フォルダを展開
" T   展開解除
" o   1ウィンドウの場合は新たにvimfilerを起動し、2ウィンドウの場合はディレクトリ位置を同期する
" Tab 1ウィンドウの場合は新たにvimfilerを起動し、2ウィンドウの場合はウィンドウを切り替える
" H   シェルを起動
" .   隠しファイルの表示非表示切り替え
"
" -- 移動 --
" hjkl フォルダ・選択移動
" \    ルートに移動
" ~    ホームに移動
"
" -- find, grep --
" gf find
" gr grep
"
" -- 編集 --
" e  ファイルの編集
" q  バッファの残して終了
" Q  終了
" gs safemode有効、無効切り替え（ファイルの作成や削除はsafemodeではできない）
" Space マーク
" c  マークしたファイルをコピー
" m  マークしたファイルを移動
" d  マークしたファイルを削除(ゴミ箱）
" dd 削除
" r  マークしたファイルの名前を変更
" K  新規ディレクトリを作成
" N  新規ファイルを作成
" *  すべてのファイルにマークをつける・マークをはずす
" U  すべてのファイルのマークをはずす
" yy ファイルのフルパスコピー

nmap [vimfiler]s :VimFiler -split -simple -winwidth=40 -no-quit<CR>
nmap [vimfiler]f :VimFiler<CR>o
nmap [vimfiler]t :tabe<CR>:VimFiler<CR>o
"vimデフォルトのエクスプローラをvimfilerで置き換える
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_edit_action = 'tabopen'


" -------------------------
" unite.vim
"
" 入力モードで開始する
" let g:unite_enable_start_insert=1
" ファイル一覧
nnoremap <silent> [unite]f :UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧(選択してペースト)
nnoremap <silent> [unite]r :Unite -buffer-name=register register<CR>
" バッファ一覧
nnoremap <silent> [unite]l :Unite buffer<CR>
" 最近使用したファイル
nnoremap <silent> [unite]u :Unite file_mru buffer<CR>
" ブックマーク一覧
nnoremap <silent> [unite]b :Unite bookmark<CR>
" ブックマーク追加
nnoremap <silent> [unite]a :UniteBookmarkAdd<CR>


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

" vimshell, vimfilerからuniteを起動して移動した時にvimshell, vimfilerへ移動する
" for Unite bookmark
autocmd FileType vimfiler call unite#custom_default_action('directory', 'cd')


" -------------------------
"  neomru.vim
"
" 最近利用したファイル
"  unite で利用
" -------------------------


" -------------------------
" unite-outline
"
" ファイルを解析し、アウトラインをuniteで表示する
" -------------------------
nnoremap <silent> [unite]o :Unite -no-quit -vertical -winwidth=30 outline<CR>


" -------------------------
"  unite-mark
"
"  マークの一覧をuniteで表示する
" -------------------------
nnoremap [unite]m :Unite mark<CR>


" -------------------------
"  vim-signature
"  show mark toggle
" -------------------------
let g:SignatureMap = {
	\ 'Leader'             : "m", 
	\ 'PurgeMarks'         : "<Space>",
	\ 'PlaceNextMark'      : ",",
    \ 'PurgeMarksAtLine'   :  "-",
	\ 'GotoNextLineByPos'  : "m;",
	\ 'GotoPrevLineByPos'  : "m:",
	\ }


" -------------------------
" EasyMotion.vim
"
" z[移動コマンド]で移動可能先をハイライトしてアルファベットで移動先を指定できる
" -------------------------
let g:EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_leader_key = "z"
let g:EasyMotion_grouping = 1   " 1ストローク選択を優先する
"equire tpope/vim-repeat to enable dot repeat support
" Jump to anywhere with only `s{char}{target}`$
" `s<CR>` repeat last find motion.
nmap s <Plug>(easymotion-s2)
nmap t <Plug>(easymotion-t2)
" Bidirectional & within line 't' motion
omap f <Plug>(easymotion-bd-fl)
omap t <Plug>(easymotion-bd-tl)

map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
map  n <Plug>(easymotion-next)
map  N <Plug>(easymotion-prev)

map zh <Plug>(easymotion-lineforward)
map zj <Plug>(easymotion-j)
map zk <Plug>(easymotion-k)
map zl <Plug>(easymotion-linebackward)
"
let g:EasyMotion_startofline = 0 " keep cursor colum when JK motion
" Use uppercase target labels and type as a lower case
let g:EasyMotion_use_upper = 1
let g:EasyMotion_smartcase = 1
let g:EasyMotion_use_smartsign_jp = 1 " JP layout


" -------------------------
" tComment
"
" Ctrl+/ でコメントアウト
" -------------------------
nmap <silent> [tcomment] :TComment<CR>


" -------------------------
" vim-seek
"
" fの2文字検索版
" sで検索を開始(sをおした後に2文字入力すると移動する）
" Sで前を検索開始
" -------------------------


" -------------------------
" vimshell
"
" vim上でshellを使えるようにします
" ,s 新しいバッファ上でShellを立ち上げる
" ,v ウィンドウ分割してShellを立ち上げる
" Tabで補完
" C-lで履歴表示　
" ,sw は、画面を４分割してvimshellを開きます
" sudo実行に関して、毎回paswordを入力する必要がある（仕様です）
" -------------------------
nmap [vimshell] :VimShell<CR>
nmap [vimshell]h :VimShellCreate<CR>
nmap [vimshell]t :VimShellTab<CR>
nmap [vimshell]p :VimShellPop<CR>
nmap [vimshell]s :VimShellCreate -split-command=split<CR>
nmap [vimshell]v :VimShellCreate -split-command=vsplit<CR>
" nmap ,sw :VimShellCreate<CR><Esc>:VimShellCreate -split-command=split<CR><Esc>:VimShellCreate -split-command=vsplit<CR><Esc><C-w>j<Esc>:VimShellCreate -split-command=vsplit<CR><Esc><C-w>k
nmap ,sw :VimFiler<CR>:VimShellCreate -split-command=split<CR><Esc>:VimShellCreate -split-command=vsplit<CR>

" プロンプトの設定
let g:vimshell_prompt = '$ '
let username = system("whoami")
let g:vimshell_user_prompt = '"(".strftime("%H:%M:%S").") [".hostname().":".getcwd()."]"'


" -------------------------
"  neocomplcache
" -------------------------
let g:neocomplcache_enable_at_startup = 1

" -------------------------
"  quickrun
"
"  ,r で一番下にウィンドウを分割させて高さ8spで実行結果を表示する
" -------------------------
nmap [quickrun] :QuickRun -outputter/buffer/split "botright 8sp"<CR>


" -------------------------
" sudo.vim
"
" root権限で、ファイルを編集したい場合、
" 通常のsudo vim を利用するとユーザのvimrcを読み込んでくれない。
" 以下のように、呼び出すとユーザのvimrcを読み込んで演習できる。
" $ vim sudo:filename
" :e sudo:filename
" :e sudo:%
" -------------------------

" -------------------------
" emmet
"
" ,e でemmet補完
" visualモード時に,e で Wrap with Abbreviation
" -------------------------
nmap <silent> [emmet] <C-y>,
vmap <silent> [emmet] <C-y>,


" -------------------------
" vim-fugitve
" -------------------------
nmap [git]s :Gstatus<CR>
nmap [git]d :Gdiff<CR>
nmap [git]a :Gwrite<CR>
nmap [git]l :Glog<CR>
nmap [git]c :Gcommit<CR>
nmap [git]b :Gblame<CR>
nmap [git]m :Gmove<CR>
nmap [git]r :Gremove<CR>


" -------------------------
" gitv
"
" gitをコミットグラフで表示しつつ、差分を確認できる
nmap [git]g :Gitv git
" ファイル単位でコミットログを確認できる
nmap [git]v :Gitv!


" -------------------------
"  vim-statify
"
"  vimを開始した時にスタートページを表示します
"  スタートページには,以下が表示され、ファイルを選択・編集できます
"  バッファ、最近開いたファイル、現在のディレクトリで最近開いたファイル
" -------------------------
 

" -------------------------
" vcscommand
" git, svnなどいろいろなvcsを同じコマンドで扱える
" <leader>cd diff
" default leader = \
" -------------------------
nmap [vcs]d :VCSDiff<CR>
nmap [vcs]u :VCSAnnotate<CR>
nmap [vcs]a :VCSAdd<CR>
nmap [vcs]l :VCSLog<CR>

