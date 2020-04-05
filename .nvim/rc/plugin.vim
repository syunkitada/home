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
" 最近利用したファイルをuniteで表示
" unite で利用
" nnoremap <silent> [unite]u :Unite file_mru buffer<CR>
" -------------------------


" -------------------------
" unite-outline
"
" ファイルを解析し、アウトラインをuniteで表示する
" -------------------------
nnoremap <silent> [unite]o :Unite -no-quit -vertical -winwidth=70 outline<CR>


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
" tComment
"
" Ctrl + / でコメントアウト
" -------------------------


" -------------------------
" vimshell
"
" vim上でshellを使えるようにします
" Tabで補完
" C-uで履歴表示(autohotkey)
" sudo実行に関して、毎回paswordを入力する必要がある（仕様です）
" -------------------------
nmap [vimshell] :VimShell<CR>
nmap [vimshell]h :VimShellCreate<CR>
nmap [vimshell]t :VimShellTab<CR>
nmap [vimshell]p :VimShellPop<CR>
nmap [vimshell]s :VimShellCreate -split-command=split<CR>
nmap [vimshell]v :VimShellCreate -split-command=vsplit<CR>
nmap [vimshell]w :VimFiler<CR>:VimShellCreate -split-command=split<CR><Esc>:VimShellCreate -split-command=vsplit<CR>

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
" 以下のように、呼び出すとユーザのvimrcを読み込んで編集できる。
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
" gitv, vim-fugitive

" Gitv
" コミットログをブラウザモードで表示
" <CR>
" O  opens in new tab
" l  open
" <C-space> next commit
" <C-p> previos commit
" all refs
nmap [git]l :Gitv<CR>
nmap [git]la :Gitv --all<CR>
" コミットログをファイルモードで表示
" <CR>             | コミット次のファイルを表示
" D                | 表示中のファイルと選択されたファイルの差分を表示
" ハイライトしてD  | 一番上と一番下のコミットの差分を表示
nmap [git]f :Gitv!<CR>

" vim-fugitive
" gitの基本機能
nmap [git]a :Gwrite<CR>
nmap [git]c :Gcommit -v<CR>
nmap [git]s :Gstatus<CR>
nmap [git]b :Gblame<CR>
nmap [git]d :Gdiff<CR>
nmap [git]p :Gpull<CR>
nmap [git]pu :Gpush<CR>

" vim-merginal
" ブランチの管理(一覧、作成、切替、削除)と、ブランチ間のマージ(およびコンフリクトの解消)
nmap [git]m :Merginal<CR>



" -------------------------
" vcscommand
" git, svnなどいろいろなvcsを同じコマンドで扱える
" <leader>cd diff
" default leader = \
" -------------------------
" nmap [vcs]l :VCSLog<CR>
" nmap [vcs]d :VCSDiff<CR>
" nmap [vcs]b :VCSBlame<CR>
" nmap [vcs]a :VCSAdd<CR>
" nmap [vcs]c :VCSCommit<CR>



" -------------------------
" syntastic
" シンタックスチェック用のプラグイン
" -------------------------
let g:syntastic_python_checkers = ["flake8"]
let g:syntastic_coffee_checkers = ['coffeelint']
let g:syntastic_css_checkers = ['csslint']
let g:syntastic_javascript_checkers = ['eslint']  "eslint require: $ yarn global add eslint


" -------------------------
" tasklist
" TODO機能
" -------------------------
nmap [tasklist] <plug>TaskList


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
nmap [fzf]b :BLines<CR>


"
" coc.nvim https://github.com/neoclide/coc.nvim
"
" You should install node, and npm.
"
" You should make directory before run vim
" $ mkdir -p ~/.config/coc/extensions
"
" If you failed install extensions by below message,
" > [coc.nvim] Error on install coc-xxx: Error: coc-xxx y.y.y requires coc.nvim >= z.z.z, prease update coc.nvim
" You shoud manually install extensions beloc commands.
" $ cd ~/.config/coc/extensions
" $ yarn add coc-json coc-yaml coc-clangd coc-tsserver coc-python coc-go
"
nmap [coc]d :call CocAction('jumpDefinition', 'tab drop')<CR>
" nmap [outline] :CocList outline<CR>

" Default extensions
" If you want to check extensions, execute this command ':CocList extensions'
call coc#add_extension(
  \ 'coc-json',
  \ 'coc-yaml',
  \ 'coc-clangd',
  \ 'coc-tsserver',
  \ 'coc-python',
  \ 'coc-go',
  \)

" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction



" Show CocConfig
" :CocConfig


" language servers
" c言語
" clangd(clangd-9) は、macroや、型定義の補完がうまくいかないので利用を止める
" cclsが良いらしいが、インストールがうまくできないので諦める
