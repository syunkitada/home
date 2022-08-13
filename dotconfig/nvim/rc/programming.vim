" ----------------------------------------------------------------------------------------------------
" indent settings
" ----------------------------------------------------------------------------------------------------
" indent
set autoindent
set tabstop=4
set shiftwidth=4
" if tab to space
set expandtab
autocmd! FileType yaml setlocal tabstop=2 shiftwidth=2
autocmd! FileType html setlocal tabstop=2 shiftwidth=2
autocmd! FileType javascript setlocal tabstop=2 shiftwidth=2
autocmd! FileType ruby setlocal tabstop=2 shiftwidth=2
autocmd! FileType markdown setlocal tabstop=2 shiftwidth=2
autocmd! FileType make setlocal noexpandtab
autocmd! FileType go   setlocal noexpandtab



" -------------------------
" syntastic
" シンタックスチェック用のプラグイン
" -------------------------
let g:syntastic_python_checkers = ["flake8"]
let g:syntastic_coffee_checkers = ['coffeelint']
let g:syntastic_css_checkers = ['csslint']
let g:syntastic_javascript_checkers = ['eslint']  "eslint require: $ yarn global add eslint

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.c,*.cpp call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction


" -------------------------
" Tagbar
" https://github.com/majutsushi/tagbar/wiki
"
" Required ctags
" sudo apt-get install exuberant-ctags
" typescriptを使う場合は以下も必要
" curl https://raw.githubusercontent.com/jb55/typescript-ctags/master/.ctags > ~/.ctags
" -------------------------
" [KEYBIND] key=_o; tags=show; action=ライトパネルでタグ一覧を表示する;
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
" SrcExpl
" -------------------------
" Set refresh time in ms
let g:SrcExpl_RefreshTime = 1000
" Is update tags when SrcExpl is opened
" TODO 見直す
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
" [KEYBIND] key=_ss; tags=show; action=SrcExplの表示・非表示を切りかえます;
" TODO SrcExplを見直す
nmap [srcexpl]s :SrcExplToggle<CR>
nmap [srcexpl]u :call g:SrcExpl_UpdateTags()<CR>
nmap [srcexpl]a :call g:SrcExpl_UpdateAllTags()<CR>
nmap [srcexpl]n :call g:SrcExpl_NextDef()<CR>
nmap [srcexpl]p :call g:SrcExpl_PrevDef()<CR>
