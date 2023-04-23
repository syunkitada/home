" 表示行移動と物理行移動を入れ替える
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

nnoremap <S-r> <C-r>

" プリフィックス
" プラグイン
nmap <Space>t [terminal]
nmap <Space>f [finder]
nmap <Space>g [git]
nmap <Space>v [vimgo]
nmap <Space>y [yank_to_teraterm]
nmap <Space>s [srcexpl]
nmap <Space>d [doc]

" signature 'Leader'             : "m"
" signature 'GotoNextLineByPos'  : "<Space>;"
" signature 'GotoPrevLineByPos'  : "<Space>:"

" EasyMotion_leader_key = "z"


" 個人的なもの
nmap <Space>y :CopyToTeraterm<CR>
vmap <Space>y  y:CopyToTeraterm<CR>
