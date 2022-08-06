" # Finder ---------------------------------------------------------------------------------------------------
"
" [fern](https://github.com/lambdalisue/fern.vim)
" ? | ヘルプ表示
" N | ファイル作成
" K | ディレクトリ作成
" D | 削除
"
" e | 開く
" E | サイドで開く
" t | タブで開く
" h | ディレクトリを閉じる
" l | ディレクトリを開ける or ファイルを開く
" k | 上へ
" j | 下へ
" s | 隠しファイル表示切替
" u | 上位のディレクトリへ
" T | ターミナルへ
"
" 再割り当てできないキー: a, .

function! s:fern_settings() abort
    nmap <silent> <buffer> p <Plug>(fern-action-project-top)
    nmap <silent> <buffer> P <Plug>(fern-action-project-top:reveal)
    nmap <silent> <buffer> D <Plug>(fern-action-remove)
    nmap <silent> <buffer> u <Plug>(fern-action-leave)
    nmap <silent> <buffer> s <Plug>(fern-action-hidden)
    nmap <silent> <buffer> r <Plug>(fern-action-rename)
    nmap <silent> <buffer> v <Plug>(fern-action-open:side)

    " Terminalモード
    nmap <silent> <buffer> T <Plug>(fern-action-terminal)
    nmap <silent> <buffer> f <Plug>(fern-action-terminal) :call feedkeys("i\n fff\n")<CR>
    nmap <silent> <buffer> g <Plug>(fern-action-terminal) :call feedkeys("i\n fgv\n")<CR>
endfunction

augroup fern_settings
  autocmd!
  autocmd FileType fern call s:fern_settings()
augroup END

" Fern . -reveal=%   | カレントディレクトリで開き、カーソルは現在開いたファイルにする
nmap [finder]f :Fern . -reveal=%<CR>
" Fern . -reveal=% -drawer | ファイラをサイドで開いたままにする（現在のバッファも表示されたまま）
nmap [finder]s :Fern . -reveal=% -drawer<CR>


" # Terminal ---------------------------------------------------------------------------------------------------
" ファイラの役割も果たすので[finder]のmappingもある（[finder]と読み替えるとよい)
nmap [finder]t :call MyOpenTerminal(":tabe\n", "t-finder", "")<cr>
nmap [terminal]t :call MyOpenTerminal(":tabe\n", "t-terminal", "")<cr>
nmap [terminal]p :call MyOpenTerminal(":tabe\n", "t-project", "cd_project_root;")<cr>
" find and cd or vim
nmap [finder]a :call MyOpenTerminal("", "t-finder-tmp", "cd_project_root; fa\n")<cr>
" find by grep
nmap [finder]g :call MyOpenTerminal("", "t-finder-tmp", "cd_project_root; fgv\n")<cr>
" find from current word
nmap [finder]. :call MyOpenTerminal("", "t-finder-tmp", "cd_project_root; fgv " . expand("<cword>") . "\n")<cr>
" find from yank
nmap [finder]y :call MyOpenTerminal("", "t-finder-tmp", "cd_project_root; fgv " . getreg('"') . "\n")<cr>
" find from internal
nmap [finder]i :call MyOpenTerminal(":split\n :wincmd j\n :resize 20\n", "", "ffv " . getreg('%:p') . "\n")<cr>
nmap [finder]I :call MyOpenTerminal("", "t-finder-tmp", "ffv " . getreg('%:p') . "\n")<cr>
" find from cache
nmap [finder]c :call MyOpenTerminal("", "t-finder-tmp", "fcv\n")<cr>

" terminalモードでは、<C-\><C-n> で Terminal-Normal
" モードになるので、<ESC>にこれを割り当てる
tnoremap <ESC> <C-\><C-n>

function! s:GetActiveBuffers()
    let l:blist = getbufinfo({'bufloaded': 1, 'buflisted': 1})
    let l:result = []
    for l:item in l:blist
        "skip unnamed buffers; also skip hidden buffers?
        if empty(l:item.name) || l:item.hidden
            continue
        endif
        call add(l:result, l:item.name)
    endfor
    return l:result
endfunction

function! s:find_tabnr(bufnr)
    for tabnr in range(1, tabpagenr("$"))
        if index(tabpagebuflist(tabnr), a:bufnr) !=# -1
            return tabnr
        endif
    endfor
    return -1
endfunction

set shell=zsh
function! MyOpenTerminal(prekeys, name, keys) abort
    " $BUFFERSのファイルを候補にできるようにするため、環境変数に入れておく
    let $VIM_BUFFERS = join(s:GetActiveBuffers(), " ")
    " VIMTERMINAL=true によって、zshrcの挙動を一部変更できるようにする
    let $VIMTERMINAL = "true"
    if a:name == ""
        call feedkeys(a:prekeys . ":terminal\n i\n" . a:keys)
    else
        if bufexists(a:name)
            " tabが開いた状態ならそこへ移動する
            let bufnr = bufnr(expand(a:name))
            let tabnr = s:find_tabnr(bufnr)
            if tabnr != -1
                call feedkeys(":q\n :tabn " . tabnr . "\n")
                return
            endif
            " そうでないなら新規タブでバッファを開く
            call feedkeys(":tabe " . a:name . "\n i\n" . a:keys)
        else
            call feedkeys(a:prekeys . ":terminal\n :file " . a:name . "\n i\n" . a:keys)
        endif
    endif
endfunction

function! OpenFromTerminal() abort
    " vim terminal modeからは以下で開かれる想定
    " $ nvr -c 'call OpenFromTerminal()' hoge.txt
    " タブが見つかった場合はファイルを閉じて、そのタブへ移動する
    if bufexists(expand("%:p"))
        let bufnr = bufnr(expand("%:p"))
        let tabnr = s:find_tabnr(bufnr)
        if tabnr != tabpagenr() && tabnr != -1
            call feedkeys(":q\n :tabn " . tabnr . "\n")
            return
        endif
    endif
    " そうでないなら何もしない（そのまま開く）
endfunction

" END ファイラ ---------------------------------------------------------------------------------------------------


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

let g:tagbar_type_markdown = {
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin' : $HOME . '/.cache/neovim-dein/repos/github.com/jszakmeister/markdown2ctags/markdown2ctags.py',
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
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
" nmap [fzf]a :Ag<CR>
" nmap [fzf]f :FZF<CR>
" nmap [fzf]l :Lines<CR>
" 
" " :Buffers
" " バッファで開いてるファイルを検索してジャンプする
" 
" " :BLines
" " バッファで開いてるファイルから全行を対象に検索してジャンプする
" nmap [fzf]b :BLines<CR>
" 
" let g:fzf_layout = { 'down': '~90%' }


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


"
" black(python formatter)
"
augroup black_on_save
  autocmd!
  autocmd BufWritePre *.py Black
augroup end
