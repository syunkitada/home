# coc

- https://github.com/neoclide/coc.nvim
- 使うのを止めたのでメモを残す
- 良かったところ
  - LanguageServer のサポートが比較的しっかりしてる
    - メッセージ表示や、補完機能、ジャンプ機能などしっかり使える
- 悪かったところ
  - LanguageServer の反応が遅い
    - 非同期でやってくれるのはいいけど、遅い(PC のスペック or WSL のせいな気もするが
  - 複数 Vim を起動して編集する場合に、LanguageServer が対応しきれてない
    - 片方の Vim で定義した変数は、もう片方の Vim では未定義扱いとなるなど
  - たまにエラーのメッセージが表示されたままになる
  - Formater がうまく機能しなかった
    - Format は別プラグインで行っていた

## Install

- dein.toml
- vista は symbol のビューアなのであってもなくてもよい

```
[[plugins]]
repo = 'https://github.com/neoclide/coc.nvim'
rev = 'v0.0.74'

# Viewer & Finder for LSP symbols and tags
[[plugins]]
repo = 'https://github.com/liuchengxu/vista.vim'
```

- 別途で、node, npm をインストールする
  - とりあえず最新のを入れておけば OK
- 別途で、各 Language Server をインストールする
  - Go
    - gopl
      - https://github.com/golang/tools/blob/master/gopls/doc/user.md
      - go get でインストールできるので導入は簡単
        - go get -u golang.org/x/tools/gopls
      - import の補完がいけてなくて使うのを止めた
      - goimport に逃げた
  - C 言語
    - clangd(clangd-9)
      - apt で入るので導入は簡単
      - macro や、型定義の補完がうまくいかないので利用を止めた
        - エラーだけ表示されるので微妙
      - ctags に逃げた
    - ccls
      - clang 良いらしいが、インストールがうまくできないので諦める
      - snap でインストールできるらしいが、WSL だと無理

## .vim

```
nmap [coc]d :call CocAction('jumpDefinition', 'tab drop')<CR>
nmap [outline] :CocList outline<CR>

" Default extensions
" If you want to check extensions, execute this command ':CocList extensions'
call coc#add_extension(
\ 'coc-json',
\ 'coc-yaml',
\ 'coc-clangd',
\ 'coc-tsserver',
\ 'coc-python',
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
return !col || getline('.')[col - 1] =~# '\s'
endfunction
```

## トラブルシューティング

#### coc の extensions がインストールできない

- 明示的に以下のディレクトリを作っておく

```
$ mkdir -p ~/.config/coc/extensions
```

#### coc の extensions がインストールできない その 2

```
> [coc.nvim] Error on install coc-xxx: Error: coc-xxx y.y.y requires coc.nvim >= z.z.z, prease update coc.nvim
```

- この場合は、手動でインストールすればとりあえず動く

```
$ cd ~/.config/coc/extensions
$ yarn add coc-json coc-yaml coc-clangd coc-tsserver coc-python coc-go
```
