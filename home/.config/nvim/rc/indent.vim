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
