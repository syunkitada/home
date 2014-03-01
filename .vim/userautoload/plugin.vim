" -------------------------
"  vimfiler
" ,fs でEclipse風のエクスプローラを開く（バッファ表示)
" ,ff でVimFilerを2画面作成
" ,ft でVimFilerを新規タブで２画面作成
"
" # 使い方
" -- 表示 --
" t   フォルダを展開
" T   展開解除
" o   1ウィンドウの場合は新たにvimfilerを起動し、2ウィンドウの場合はディレクトリ位置を同期する
" Tab 1ウィンドウの場合は新たにvimfilerを起動し、2ウィンドウの場合はウィンドウを切り替える
" H   シェルを起動
"
" -- 移動 --
" hjkl フォルダ・選択移動
" \    ルートに移動
" ~    ホームに移動
" $    ゴミ箱に移動 (uコマンドでファイルの復元)
"
" -- 編集 --
" e  ファイルの編集
" q  バッファの残して終了
" Q  終了
" c  マークしたファイルをコピー
" m  マークしたファイルを移動
" d  マークしたファイルを削除(ゴミ箱）
" D  マークしたファイルを完全削除(rm相当)
" u  ファイルをゴミ箱から復元
" r  マークしたファイルの名前を変更
" K  新規ディレクトリを作成
" N  新規ファイルを作成
" *  すべてのファイルにマークをつける・マークをはずす
" U  すべてのファイルのマークをはずす
" -------------------------
nmap ,fs :VimFiler -split -simple -winwidth=40 -no-quit<CR>
nmap ,ff :VimFiler<CR>o
nmap ,ft :tabe<CR>:VimFiler<CR>o
"vimデフォルトのエクスプローラをvimfilerで置き換える
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_edit_action = 'tabopen'


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
" z[移動コマンド]で移動可能先をハイライトしてアルファベットで移動先を指定できる
" -------------------------
let g:EasyMotion_keys = 'hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
let g:EasyMotion_leader_key = "z"
let g:EasyMotion_grouping = 1   " 1ストローク選択を優先する

" -------------------------
" tComment
" Ctrl+/ でコメントアウト
" -------------------------
map <silent> <C-/> :TComment<CR>


" -------------------------
" vim-seek
" fの2文字検索版
" sで検索を開始(sをおした後に2文字入力すると移動する）
" Sで前を検索開始
" -------------------------


" -------------------------
"  visualmark
"  行をハイライトしてマークする
"  F3でマークし、もう一度F3でマークを取り消す
"  F2でマークした箇所を順に移動する
" -------------------------
map <F3> <Plug>Vm_toggle_sign
map <silent> mm <Plug>Vm_toggle_sign


" -------------------------
" vimshell
" vim上でshellを使えるようにします
" ,s 新しいバッファ上でShellを立ち上げる
" ,v ウィンドウ分割してShellを立ち上げる
" Tabで補完
" C-lで履歴表示　
" ,sw は、画面を４分割してvimshellを開きます
" sudo実行に関して、毎回paswordを入力する必要がある（仕様です）
" -------------------------
nmap ,s :VimShell<CR>
nmap ,sh :VimShellCreate<CR>
nmap ,st :VimShellTab<CR>
nmap ,sp :VimShellPop<CR>
nmap ,ss :VimShellCreate -split-command=split<CR>
nmap ,sv :VimShellCreate -split-command=vsplit<CR>
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
"  ,r で一番下にウィンドウを分割させて高さ8spで実行結果を表示する
" -------------------------
nmap ,r :QuickRun -outputter/buffer/split "botright 8sp"<CR>


" -------------------------
" sudo.vim
" root権限で、ファイルを編集したい場合、
" 通常のsudo vim を利用するとユーザのvimrcを読み込んでくれない。
" 以下のように、呼び出すとユーザのvimrcを読み込んで演習できる。
" $ vim sudo:filename
" :e sudo:filename
" :e sudo:%
" -------------------------

" -------------------------
" emmet
" ,e でemmet補完
" visualモード時に,e で Wrap with Abbreviation
" -------------------------
nmap <silent> ,e <C-y>,
vmap <silent> ,e <C-y>,


" -------------------------
" vim-fugitve
" -------------------------
nmap ,gs :Gstatus
nmap ,gd :Gdiff
nmap ,ga :Gwrite
nmap ,gl :Glog
nmap ,gc :Gcommit
nmap ,gb :Gblame
nmap ,gm :Gmove
nmap ,gr :Gremove


" -------------------------
" gitv
" -------------------------
" gitをコミットグラフで表示しつつ、差分を確認できる
nmap ,gg :Gitv git
" ファイル単位でコミットログを確認できる
nmap ,gv :Gitv!

