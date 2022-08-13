" # Finder ---------------------------------------------------------------------------------------------------
"
" [fern](https://github.com/lambdalisue/fern.vim)
" [KEYBIND] mode=vf; key=?; tags=show; action=ヘルプを表示します;
" [KEYBIND] mode=vf; key=N; tags=edit; action=新規ファイルを作成します;
" [KEYBIND] mode=vf; key=K; tags=edit; action=新規ディレクトリを作成します;
" [KEYBIND] mode=vf; key=D; tags=edit; action=ファイルを削除します;
" [KEYBIND] mode=vf; key=r; tags=edit; action=ファイル名を変更します;
" [KEYBIND] mode=vf; key=e; tags=open; action=カレントバッファでターゲットを開きます;
" [KEYBIND] mode=vf; key=E; tags=open; action=サイドパネルでターゲットを開きます;
" [KEYBIND] mode=vf; key=t; tags=open; action=タブでターゲットを開きます;
" [KEYBIND] mode=vf; key=h; tags=move; action=ディレクトリを閉じます;
" [KEYBIND] mode=vf; key=l; tags=move; action=ディレクトリを開ける or ファイルを開きます;
" [KEYBIND] mode=vf; key=k; tags=move; action=カーソルを上へ移動します;
" [KEYBIND] mode=vf; key=j; tags=move; action=カーソルを下へ移動します;
" [KEYBIND] mode=vf; key=u; tags=move; action=上位のディレクトリへ移動します;
" [KEYBIND] mode=vf; key=p; tags=move; action=プロジェクトのトップへ移動します;
" [KEYBIND] mode=vf; key=P; tags=move; action=プロジェクトのトップへ移動します（カーソルは維持したまま）;
" [KEYBIND] mode=vf; key=s; tags=show; action=隠しファイル表示を切り替えます;
" [KEYBIND] mode=vf; key=T; tags=move; action=ターミナルモードへ移行します;
" [KEYBIND] mode=vf; key=f; tags=move; action=ターミナルモードへ移行し、ファイル検索モードへ移行します;
" [KEYBIND] mode=vf; key=F; tags=move; action=ターミナルモードへ移行し、文字列検索モードへ移行します;
"
" 再割り当てできないキー: a, .

function! s:fern_settings() abort
    nmap <silent> <buffer> p <Plug>(fern-action-project-top)
    nmap <silent> <buffer> P <Plug>(fern-action-project-top:reveal)
    nmap <silent> <buffer> D <Plug>(fern-action-remove)
    nmap <silent> <buffer> u <Plug>(fern-action-leave)
    nmap <silent> <buffer> s <Plug>(fern-action-hidden)
    nmap <silent> <buffer> r <Plug>(fern-action-rename)

    " Terminalモード
    nmap <silent> <buffer> T <Plug>(fern-action-terminal)
    nmap <silent> <buffer> f <Plug>(fern-action-terminal) :call feedkeys("i\n fff\n")<CR>
    nmap <silent> <buffer> F <Plug>(fern-action-terminal) :call feedkeys("i\n fgv\n")<CR>
endfunction

augroup fern_settings
  autocmd!
  autocmd FileType fern call s:fern_settings()
augroup END

" [KEYBIND] key=_ff; tags=finder; action=カレントディレクトリをファイラで開き、カーソルは現在開いたファイルにする
" Fern . -reveal=%   | カレントディレクトリで開き、カーソルは現在開いたファイルにする
nmap [finder]f :Fern %:h -reveal=%p<CR>
" [KEYBIND] key=_fs; tags=finder; action=サイドパネルで、カレントディレクトリをファイラで開き、カーソルは現在開いたファイルにする
" Fern . -reveal=% -drawer | ファイラをサイドパネルで開いたままにする（現在のバッファも表示されたまま）
nmap [finder]s :Fern %:h -reveal=%p -drawer<CR>


"
" ファイル移動のためにターミナルモードを経由するショートカット
"

" [KEYBIND] key=_ft; tags=finder,terminal; action=t-findrバッファでターミナルモードへ移行します;
nmap [finder]t :call MyOpenTerminal(":tabe\n", "t-finder", "")<cr>
" [KEYBIND] key=_fa; tags=finder,terminal; action=新しいタブでターミナルモードへ移行し、プロジェクトトップへ移動して、fa(find any)します;
nmap [finder]a :call MyOpenTerminal(":tabe\n", "t-finder-tmp", "cd_project_root; fa\n")<cr>
" [KEYBIND] key=_fg; tags=finder,terminal; action=新しいタブでターミナルモードへ移行し、プロジェクトトップへ移動して、fgv(grep and vim)します;
nmap [finder]g :call MyOpenTerminal(":tabe\n", "t-finder-tmp", "cd_project_root; fgv\n")<cr>
" [KEYBIND] key=_f.; tags=finder,terminal; action=新しいタブでターミナルモードへ移行し、プロジェクトトップへ移動して、カーソル位置のワードでfgv(grep and vim)します;
nmap [finder]. :call MyOpenTerminal(":tabe\n", "t-finder-tmp", "cd_project_root; fgv " . expand("<cword>") . "\n")<cr>
" [KEYBIND] key=_fy; tags=finder,terminal; action=新しいタブでターミナルモードへ移行し、プロジェクトトップへ移動して、yankしたワードでfgv(grep and vim)します;
nmap [finder]y :call MyOpenTerminal(":tabe\n", "t-finder-tmp", "cd_project_root; fgv " . getreg('"') . "\n")<cr>
" [KEYBIND] key=_fi; tags=finder,terminal; action=ボトムパネルでターミナルを開き、ファイル内の文字列検索を行います;
nmap [finder]i :call MyOpenTerminal(":split\n :wincmd j\n :resize 20\n", "", "ffv " . getreg('%:p') . "\n")<cr>
" [KEYBIND] key=_fI; tags=finder,terminal; action=カレントバッファでターミナルモードへ移行し、ファイル内の文字列検索を行います;
nmap [finder]I :call MyOpenTerminal("", "t-finder-tmp", "ffv " . getreg('%:p') . "\n")<cr>
" [KEYBIND] key=_fc; tags=finder,terminal; action=新しいタブでターミナルモードへ移行し、fcv(find from cache and vim)します;
nmap [finder]c :call MyOpenTerminal(":tabe\n", "t-finder-tmp", "fcv\n")<cr>

" [KEYBIND] key=_tt; tags=terminal; action=t-terminalバッファでターミナルモードへ移行します;
nmap [terminal]t :call MyOpenTerminal(":tabe\n", "t-terminal", "")<cr>
" [KEYBIND] key=_tp; tags=terminal; action=t-projectバッファでターミナルモードへ移行し、プロジェクトトップへ移動します;
nmap [terminal]p :call MyOpenTerminal(":tabe\n", "t-project", "cd_project_root;")<cr>


" terminalモードでは、<C-\><C-n> で Terminal-Normal
" モードになるので、<ESC>にこれを割り当てる
" [KEYBIND] mode=vt; key=<ESC>; tags=terminal; action=ノーマルモードへ移行します;
tnoremap <ESC> <C-\><C-n>

function! s:get_active_buffers()
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
    let $VIM_BUFFERS = join(s:get_active_buffers(), " ")
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
" [KEYBIND] key=s; tags=move; action=easymotionへ移行します;
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

" [KEYBIND] key=_gl; tags=git,show; action=git logを表示します;
nmap [git]l :Agit<CR>

" vim-gitgutter
" [KEYBIND] key=_gg; tags=git,show; action=gitgutterのマーカの表示非表示を切り替えます（デフォルトは表示）;
nmap [git]g :GitGutterToggle<CR>

" vim-fugitive
" gitの基本機能
" [KEYBIND] key=_ga; tags=git,edit; action=git addします;
nmap [git]a :Gwrite<CR>
" [KEYBIND] key=_gc; tags=git,edit; action=git commitします;
nmap [git]c :Gcommit -v<CR>
" [KEYBIND] key=_gs; tags=git,show; action=git statusします;
nmap [git]s :Gstatus<CR>
" [KEYBIND] key=_gb; tags=git,show; action=git blameします;
nmap [git]b :Gblame<CR>
" [KEYBIND] key=_gd; tags=git,show; action=git diffします;
nmap [git]d :Gdiff<CR>
" [KEYBIND] key=_gp; tags=git,update; action=git pullします;
nmap [git]p :Gpull<CR>
" [KEYBIND] key=_gu; tags=git,update; action=git pushします;
nmap [git]P :Gpush<CR>


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
