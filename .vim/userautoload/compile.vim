" コンパイルして実行
augroup MyGroup
    autocmd Filetype c command! Compile call CCompile()
    autocmd Filetype cpp command! Compile call CppCompile()
    autocmd Filetype python command! Compile call PyCompile()
    autocmd Filetype perl command! Compile call PlCompile()
    autocmd Filetype ruby command! Compile call RbCompile()
augroup END
function! CCompile()
    echo compile
endfunction
function! CppCompile()
    echo compile
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

map ,c :Compile<CR>
