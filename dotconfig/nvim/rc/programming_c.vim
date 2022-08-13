" ----------------------------------------------------------------------------------------------------
"  clang
" ----------------------------------------------------------------------------------------------------


" ----------------------------------------------------------------------------------------------------
" clang format
" ----------------------------------------------------------------------------------------------------
autocmd BufWritePre *.c,*.h ClangFormat
let g:clang_format#code_style = "google"
let g:clang_format#style_options = {
            \ "ColumnLimit": 120}

"
" quicker-cscope
" https://github.com/ronakg/quickr-cscope.vim
" Require cscope
"
" TODO 見直す
nmap [cscope]c <plug>(quickr_cscope_symbols)
nmap [cscope]f <plug>(quickr_cscope_files)
" ----------------------------------------------------------------------------------------------------
