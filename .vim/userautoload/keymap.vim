" 表示行移動と物理行移動を入れ替える
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

nnoremap <S-r> <C-r>

" プリフィックス
" プラグイン
nmap <Space>f [vimfiler]
nmap <Space>u [unite]
nmap <Space>s [vimshell]
nmap <Space>r [quickrun]
nmap <Space>e [emmet]
nmap <Space>g [git]
nmap <Space>y [yank_to_teraterm]
nmap <Space>t [tasklist]
" signature 'Leader'             : "m"
" signature 'GotoNextLineByPos'  : "<Space>;"
" signature 'GotoPrevLineByPos'  : "<Space>:"

" EasyMotion_leader_key = "z"


" 個人的なもの
nmap <Space>y :CopyToTeraterm<CR>
vmap <Space>y  y:CopyToTeraterm<CR>
