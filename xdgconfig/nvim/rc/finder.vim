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
    nmap <silent> <buffer> f <Plug>(fern-action-terminal) :call feedkeys("i\n fa\n")<CR>
    nmap <silent> <buffer> F <Plug>(fern-action-terminal) :call feedkeys("i\n fgv\n")<CR>
endfunction

augroup fern_settings
  autocmd!
  autocmd FileType fern call s:fern_settings()
augroup END

" :Fern .               | Fernを開きます
" :Fern . -drawer       | サイドパネルでFernを開きます
" :Fern . -reveal=%     | Fernを開き、カーソルを現在開いてるファイルにします
" :Fern %:h             | カレントバッファの親ディレクトリを起点にFernを開きます
" :Fern %:h -reveal=%:p | カレントバッファの親ディレクトリを起点にFernを開き、カーソルを現在開いてるファイルにします
"   Referece: [How to open fern on a parent directory of a current buffer and focus](https://github.com/lambdalisue/vim-fern/issues/295)
"
" [KEYBIND] key=_fo; tags=finder; action=ファイラを開く（すでにtabが開かれてる場合はtabに移動する）
nmap [finder]o :call MyOpenFern()<CR>
" [KEYBIND] key=_fg; tags=finder; action=カレントディレクトリをファイラで開き、カーソルは現在開いたファイルにする
nmap [finder]g :Fern %:h -reveal=%:p<CR>
" [KEYBIND] key=_fs; tags=finder; action=サイドパネルで、カレントディレクトリをファイラで開き、カーソルは現在開いたファイルにする
nmap [finder]s :Fern %:h -reveal=%:p -drawer<CR>

function! s:find_ferntabnr()
    for tabnr in range(1, tabpagenr("$"))
        for tabpagebuf in tabpagebuflist(tabnr)
            if stridx(bufname(tabpagebuf), "fern:") == 0
                return tabnr
            endif
        endfor
    endfor
    echo "debug end"
    return -1
endfunction

function! MyOpenFern()
    " fern tabを検索してあればそれをそのままtab移動する
    let tabnr = s:find_ferntabnr()
    if tabnr != tabpagenr() && tabnr != -1
        call feedkeys(":tabn " . tabnr . "\n")
        return
    endif

    " tabがなければfernを横二分割で開く
    if line('$') != 1 || getline(1) != ''
        call feedkeys(":tabnew\n")
    endif
    call feedkeys(":tabm 0\n")
    call feedkeys(":Fern %:h -reveal=%p\n")
    call feedkeys(":sleep 1000m\n")
    call feedkeys(":vs\n")
endfunction

"
" FZF
" https://github.com/junegunn/fzf/wiki/Examples-(vim)
"
set rtp+=~/.fzf
let g:fzf_action = {'tab': 'tab split'}

" [KEYBIND] key=_ff; tags=finder,fzf; action=FZFでファイルを検索します;
nmap [finder]f :Files<cr>
" [KEYBIND] key=_ft; tags=finder,fzf; action=FZFでテキストを検索します;
nmap [finder]t :Ag<cr>
" [KEYBIND] key=_fb; tags=finder,fzf; action=FZFでバッファファイルを検索します;
nmap [finder]b :Buffers<cr>
" [KEYBIND] key=_fi; tags=finder,fzf; action=FZFでバッファいファイル内のテキストを検索します;
nmap [finder]i :FZFLines<cr>
" [KEYBIND] key=_fh; tags=finder,fzf; action=FZFで最近開いたファイルを検索します;
nmap [finder]h :FZFMru<cr>

function! s:line_handler(l)
  let keys = split(a:l, ':\t')
  exec 'buf' keys[0]
  exec keys[1]
  normal! ^zz
endfunction

function! s:buffer_lines()
  let res = []
  for b in filter(range(1, bufnr('$')), 'buflisted(v:val)')
    call extend(res, map(getbufline(b,0,"$"), 'b . ":\t" . (v:key + 1) . ":\t" . v:val '))
  endfor
  return res
endfunction

command! FZFLines call fzf#run({
\   'source':  <sid>buffer_lines(),
\   'sink':    function('<sid>line_handler'),
\   'options': '--extended --nth=3..',
\   'down':    '60%'
\})

command! FZFMru call fzf#run({
\  'source':  v:oldfiles,
\  'sink':    'e',
\  'options': '-m -x +s',
\  'down':    '40%'})

"
" ファイル移動のためにターミナルモードを経由するショートカット
"

" [KEYBIND] key=_tt; tags=terminal; action=t-terminalバッファでターミナルモードへ移行します;
nmap [terminal]t :call MyOpenTerminal(":tabe\n", "t-terminal", "")<cr>
" [KEYBIND] key=_tf; tags=finder,terminal; action=t-findrバッファでターミナルモードへ移行します;
nmap [terminal]f :call MyOpenTerminal(":tabe\n", "t-finder", "")<cr>
" [KEYBIND] key=_tp; tags=terminal; action=t-projectバッファでターミナルモードへ移行し、プロジェクトトップへ移動します;
nmap [terminal]p :call MyOpenTerminal(":tabe\n", "t-project", "cd_project_root\n")<cr>


" terminalモードでは、<C-\><C-n> で Terminal-Normal
" モードになるので、<ESC>にこれを割り当てる
" [KEYBIND] mode=vt; key=<ESC>; tags=terminal; action=ノーマルモードへ移行します;
tnoremap <ESC> <C-\><C-n>
" [KEYBIND] mode=vt; key=<ESC><ESC>; tags=terminal; action=ターミナルモードを閉じます;
tnoremap <ESC><ESC> <C-\><C-n>:q<CR>


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


" 環境変数 VIMTERMINAL=true とセットしておくことで、terminal時のzshrcの挙動を一部変更できるようにします
" 例えば、vim terminalでは、vimのaliasにnvrを利用するなど（これによりnestedでvimを起動しないようにできる）
let $VIMTERMINAL = "true"
set shell=zsh
function! MyOpenTerminal(prekeys, name, keys) abort
    " $BUFFERSのファイルを候補にできるようにするため、環境変数に入れておく
    let $VIM_BUFFERS = join(s:get_active_buffers(), " ")
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
