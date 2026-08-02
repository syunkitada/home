" 表示行移動と物理行移動を入れ替える
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

nnoremap <S-r> <C-r>

" <C-w>は、ブラウザのシュートカットにバッティングするため、ウィンドウ操作を<C-z>でもできるようにする
nnoremap <C-z>h <C-w>h
nnoremap <C-z>j <C-w>j
nnoremap <C-z>k <C-w>k
nnoremap <C-z>l <C-w>l

" forward-word
" backward-word
" <C-o> は Insert モードを維持したまま Normal モードのコマンドを1つだけ実行します。
nnoremap <C-Right> w
nnoremap <C-Left>  b
inoremap <C-Right> <C-o>w
inoremap <C-Left>  <C-o>b

" Prefix keys
nmap <Space>t [terminal]
nmap <Space>f [finder]
nmap <Space>g [git]
nmap <Space>v [vimgo]
nmap <Space>y [yank_to_teraterm]
nmap <Space>s [srcexpl]
nmap <Space>d [doc]
nmap <Space><Space> [holon]

