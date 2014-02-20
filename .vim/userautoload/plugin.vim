
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
" -------------------------
nmap ,s :VimShell<CR>
nmap ,sh :VimShell<CR>
nmap ,st :VimShellTab<CR>
nmap ,sp :VimShellPop<CR>

" プロンプトの設定
let g:vimshell_prompt = '$ '
let username = system("whoami")
let g:vimshell_user_prompt = '"(".strftime("%H:%M:%S").") [".hostname().":".getcwd()."]"'


" -------------------------
"  neocomple
let g:neocomplcache_enable_at_startup = 1


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

