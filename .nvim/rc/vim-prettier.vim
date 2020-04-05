" vim-prettier
" https://github.com/prettier/vim-prettier

" coc-prettier is not working as well
" https://github.com/neoclide/coc-prettier

" # Prepare requirements
" $ yarn global add prettier prettier/vim-prettier
"
" # setting PATH
" export PATH=${PATH}:${HOME}/.yarn/bin

" Running before saving async
" let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync
" autocmd TextChanged,InsertLeave *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

" This should be changed automatically
let g:prettier#config#parser = 'typescript'
