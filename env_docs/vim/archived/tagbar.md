# tagbar

```
# tagbar is plugin to display tag list in side bar
# this plugin require ctags
[[plugins]]
repo = 'https://github.com/majutsushi/tagbar.git'

# for viewing markdown on tagbar
[[plugins]]
repo = 'https://github.com/jszakmeister/markdown2ctags.git'
```


```
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
```
