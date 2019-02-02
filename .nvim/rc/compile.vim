" コンパイルして実行
augroup MyGroup
    autocmd Filetype c command! Compile call CCompile()
    autocmd Filetype cpp command! Compile call CppCompile()
    autocmd Filetype python command! Compile call PyCompile()
    autocmd Filetype perl command! Compile call PlCompile()
    autocmd Filetype ruby command! Compile call RbCompile()
    autocmd Filetype php command! Compile call PHPCompile()
augroup END
function! CCompile()
	:w
	:!gcc % -o %.out && ./%.out
endfunction
function! CppCompile()
	:w
	:!g++ % -o %.out && ./%.out
endfunction
function! PyCompile()
    :w
    :!python %
endfunction
function! PlCompile()
    :w
    :!perl %
endfunction
function! RbCompile()
    :w
    :!ruby %
endfunction
function! PHPCompile()
    :w
    :!php %
endfunction

" quick run があるからいらないかも？
" map ,r :Compile<CR>
