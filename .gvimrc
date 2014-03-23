"colorscheme twilight
colorscheme molokai

" visualize tab
highlight Tab guibg=#303030
	au BufWinEnter * let w:m1 = matchadd("Tab", '\t')
au WinEnter * let w:m1 = matchadd("Tab", '\t')

" visualize eol of space and tab
highlight WhitespaceEOL guibg=#ff6666
au BufWinEnter * let w:m1 = matchadd("WhitespaceEOL", '[ \t]\+$')
au WinEnter * let w:m1 = matchadd("WhitespaceEOL", '[ \t]\+$')

" visualize double-byte space
highlight ZenkakuSpace gui=underline guibg=#ff6666
au BufWinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')
au WinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')

gui
set transparency=225

