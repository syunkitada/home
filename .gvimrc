" colorscheme twilight
" colorscheme molokai
colorscheme hybrid

" visualize tab
highlight Tab guibg=#303030
	au BufWinEnter * let w:m1 = matchadd("Tab", '\t')
au WinEnter * let w:m1 = matchadd("Tab", '\t')

" visualize eol of space and tab
highlight WhitespaceEOL guibg=#4e4e4e
au BufWinEnter * let w:m1 = matchadd("WhitespaceEOL", '[ \t]\+$')
au WinEnter * let w:m1 = matchadd("WhitespaceEOL", '[ \t]\+$')

" visualize double-byte space
highlight ZenkakuSpace gui=underline guibg=#ff6666
au BufWinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')
au WinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')

set guioptions+=a
set transparency=225

" search
set hlsearch
set incsearch
set ignorecase
set smartcase

" show number of lines
set number

" enable mouse operation
set mouse=nv

" support 'GNU Screen'
set ttymouse=xterm2

set clipboard=unnamed,autoselect

" 英語メニューにする
source $VIMRUNTIME/delmenu.vim 
set langmenu=none 
source $VIMRUNTIME/menu.vim

" 英語メッセージにする
if has("multi_lang")
    language C
endif

