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
" E  スプリットしてファイルの編集
" q  バッファの残して終了
" Q  終了
" gs safemode有効、無効切り替え（ファイルの作成や削除はsafemodeではできない）
"
" Space マーク
" c  マークしたファイルをコピー
" cc カーソル下のファイルをコピー
" m  マークしたファイルを移動
" mm カーソル下のファイルをコピー
" d  マークしたファイルを削除(ゴミ箱）
" dd 削除
" r  マークしたファイルの名前を変更
" K  新規ディレクトリを作成
" N  新規ファイルを作成
" *  すべてのファイルにマークをつける・マークをはずす
" U  すべてのファイルのマークをはずす
" yy ファイルのフルパスコピー
"
" 補足
" c, m, dはマークされてるファイルがないときは、カーソル下のファイルをマークする
" このため、cc, mm, ddなどと入力すればカーソル下のファイルを操作できる
"
" また、m, cによるファイルの移動、コピーは、
" 2画面の時は他方のディレクトリへの移動、コピーとなる
" 1画面の時は移動先を聞かれるのでパスを入力する
"
" その他
" x  システム関連付けを実行
" E  外部ファイラでファイルを開く

nmap [vimfiler]s :VimFiler -split -simple -winwidth=40 -no-quit<CR>
nmap [vimfiler]r :VimFiler<CR>
nmap [vimfiler]f :VimFiler<CR>O
nmap [vimfiler]t :tabe<CR>:VimFiler<CR>o
nmap [vimfiler]o :VimFiler -split -simple -winwidth=40 -no-quit<CR>:TagbarToggle<CR><C-w>l
"vimデフォルトのエクスプローラをvimfilerで置き換える
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_edit_action = 'tabopen'
let g:vimfiler_enable_auto_cd = 1



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
" ブックマークの削除
" d でカーソル位置のブックマークを削除



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
let g:EasyMotion_grouping = 1   " 1ストローク選択を優先する
"equire tpope/vim-repeat to enable dot repeat support
" Jump to anywhere with only `s{char}{target}`$
" `s<CR>` repeat last find motion.
nmap s <Plug>(easymotion-s)
" Bidirectional & within line 't' motion
omap s <Plug>(easymotion-s)
vmap s <Plug>(easymotion-s)
" nmap t <Plug>(easymotion-t)
" vmap t <Plug>(easymotion-t)
" omap f <Plug>(easymotion-bd-fl)
" omap t <Plug>(easymotion-bd-tl)
" vmap f <Plug>(easymotion-bd-fl)
" vmap t <Plug>(easymotion-bd-tl)

" nmap / <Plug>(easymotion-sn)
" omap / <Plug>(easymotion-tn)
" vmap / <Plug>(easymotion-tn)
" map  n <Plug>(easymotion-next)
" map  N <Plug>(easymotion-prev)

let g:EasyMotion_startofline = 0 " keep cursor colum when JK motion
" Use uppercase target labels and type as a lower case
let g:EasyMotion_use_upper = 1
let g:EasyMotion_smartcase = 1
let g:EasyMotion_use_smartsign_jp = 1 " JP layout



" -------------------------
" git: agit, vim-gitgutter, vim-fugitive

" show git log
nmap [git]l :Agit<CR>

" vim-gitgutter
nmap [git]g :GitGutterToggle<CR>

" vim-fugitive
" gitの基本機能
nmap [git]a :Gwrite<CR>
nmap [git]c :Gcommit -v<CR>
nmap [git]s :Gstatus<CR>
nmap [git]b :Gblame<CR>
nmap [git]d :Gdiff<CR>
nmap [git]p :Gpull<CR>
nmap [git]pu :Gpush<CR>


" -------------------------
" syntastic
" シンタックスチェック用のプラグイン
" -------------------------
let g:syntastic_python_checkers = ["flake8"]
let g:syntastic_coffee_checkers = ['coffeelint']
let g:syntastic_css_checkers = ['csslint']
let g:syntastic_javascript_checkers = ['eslint']  "eslint require: $ yarn global add eslint



" -------------------------
" Tagbar
" https://github.com/majutsushi/tagbar/wiki
"
" Required ctags
" sudo apt-get install exuberant-ctags
" typescriptを使う場合は以下も必要
" curl https://raw.githubusercontent.com/jb55/typescript-ctags/master/.ctags > ~/.ctags
" -------------------------
nmap  [outline] :TagbarToggle<CR>
let g:tagbar_type_typescript = {
  \ 'ctagstype': 'typescript',
  \ 'kinds': [
    \ 'c:classes',
    \ 'n:modules',
    \ 'f:functions',
    \ 'v:variables',
    \ 'v:varlambdas',
    \ 'm:members',
    \ 'i:interfaces',
    \ 'e:enums',
  \ ]
\ }



" -------------------------
" lightline
" -------------------------
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified', 'method' ] ]
      \ },
      \ 'component_function': {
      \   'method': 'NearestMethodOrFunction'
      \ },
      \ }


function! MyModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help' && &readonly ? '-R' : ''
endfunction

function! MyFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
        \ &ft == 'unite' ? unite#get_status_string() :
        \ &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = ''  " edit here for cool mark
      let _ = fugitive#head()
      return strlen(_) ? mark._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == 'ControlP' ? 'CtrlP' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ &ft == 'unite' ? 'Unite' :
        \ &ft == 'vimfiler' ? 'VimFiler' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! CtrlPMark()
  if expand('%:t') =~ 'ControlP'
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.c,*.cpp call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0


" -------------------------
" SrcExpl
" -------------------------
" Set refresh time in ms
let g:SrcExpl_RefreshTime = 1000
" Is update tags when SrcExpl is opened
let g:SrcExpl_isUpdateTags = 0
" Tag update command
let g:SrcExpl_updateTagsCmd = 'ctags --sort=foldcase %'
" Update all tags
function! g:SrcExpl_UpdateAllTags()
let g:SrcExpl_updateTagsCmd = 'ctags --sort=foldcase -R .'
call g:SrcExpl_UpdateTags()
let g:SrcExpl_updateTagsCmd = 'ctags --sort=foldcase %'
endfunction
" Source Explorer Window Height
let g:SrcExpl_winHeight = 14
" Mappings
" nm <Leader>E [srce]
" nmap <Space>h :SrcExplToggle<CR>
nmap [srcexpl]s :SrcExplToggle<CR>
nmap [srcexpl]u :call g:SrcExpl_UpdateTags()<CR>
nmap [srcexpl]a :call g:SrcExpl_UpdateAllTags()<CR>
nmap [srcexpl]n :call g:SrcExpl_NextDef()<CR>
nmap [srcexpl]p :call g:SrcExpl_PrevDef()<CR>


"
" fzf
" Require fzf, silversearcher-ag
"
nmap [fzf]a :Ag<CR>
nmap [fzf]f :FZF<CR>
nmap [fzf]l :Lines<CR>

" :Buffers
" バッファで開いてるファイルを検索してジャンプする

" :BLines
" バッファで開いてるファイルから全行を対象に検索してジャンプする
nmap [fzf]b :BLines<CR>

let g:fzf_layout = { 'down': '~90%' }


" :History


" :Marks
" マーク一覧をファイル名で検索してジャンプできる


" deoplete
" https://github.com/Shougo/deoplete.nvim
" Require Run `:UpdateRemotePlugins`
let g:deoplete#enable_at_startup = 1


"
" clang format
"
autocmd BufWritePre *.c,*.h ClangFormat
let g:clang_format#code_style = "google"
let g:clang_format#style_options = {
            \ "ColumnLimit": 120}

"
" quicker-cscope
" https://github.com/ronakg/quickr-cscope.vim
" Require cscope
"
nmap [cscope]c <plug>(quickr_cscope_symbols)
nmap [cscope]f <plug>(quickr_cscope_files)
