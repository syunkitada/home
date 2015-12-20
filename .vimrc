" vim_starting is true only at start up
if has('vim_starting')
    " ---------- NeoBundle required ----------
    set nocompatible
    set runtimepath+=~/.vim/bundle/neobundle.vim/
    " ---------- NeoBundle end ---------------

    " autoload my vimscripts
    runtime! userautoload/*.vim
endif


" ---------- NeoBundle ----------
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'


" plugins
NeoBundleLazy 'https://github.com/Shougo/unite.vim', 'ver.6.1', {
    \'autoload' : {'commands': ['Unite', 'UniteWithBufferDir']}}
NeoBundleLazy 'https://github.com/Shougo/vimfiler.vim', 'ver.4.1', {
    \'autoload': {'commands': ['VimFiler']}}
" NeoBundle 'https://github.com/scrooloose/nerdtree'  " NERDTree is filer like vimfiler, bat this will sumetimes freeze
NeoBundleLazy 'https://github.com/Shougo/neocomplcache', {
    \'autoload': {'insert': 1}}
NeoBundleLazy 'https://github.com/Shougo/vimshell', {
    \'autoload': {'commands': ['VimShell', 'VimShellCreate', 'VimShellPop', 'VimShellTab']}}
NeoBundle 'https://github.com/Shougo/neomru.vim'
NeoBundle 'https://github.com/Shougo/vimproc', 'ver.7.1', {
    \'build' : {
    \        'windows' : 'make -f make_mingw32.mak',
    \        'cygwin' : 'make -f make_cygwin.mak',
    \        'mac' : 'make -f make_mac.mak',
    \        'unix' : 'make -f make_unix.mak',
    \    },
    \}
NeoBundle 'https://github.com/tacroe/unite-mark'
NeoBundle 'https://github.com/vim-scripts/tComment'
NeoBundle 'https://github.com/vim-scripts/sudo.vim'
NeoBundle 'https://github.com/kshenoy/vim-signature'
NeoBundle 'https://github.com/Lokaltog/vim-easymotion'
NeoBundle 'https://github.com/thinca/vim-quickrun'
NeoBundleLazy 'https://github.com/mattn/emmet-vim.git', {
    \'autoload': {'filetypes': ['html']}}
NeoBundle 'https://github.com/tpope/vim-surround.git'
NeoBundle 'https://github.com/scrooloose/syntastic.git'
NeoBundleLazy 'https://github.com/vim-scripts/TaskList.vim', {
    \ 'autoload': {'mappings': ['<Plug>TaskList']}}
NeoBundle 'https://github.com/kchmck/vim-coffee-script.git'
NeoBundle 'https://github.com/majutsushi/tagbar.git'
" NeoBundle 'https://github.com/vim-scripts/taglist.vim'  " Taglist is show outline of tag like Tagbar, however Tagbar is easy to see than this.
NeoBundle 'https://github.com/itchyny/lightline.vim.git'
NeoBundle 'https://github.com/wesleyche/SrcExpl'

" NeoBundle 'https://github.com/vim-scripts/vcscommand.vim' all vcsなプラグイン
" for git
NeoBundle 'https://github.com/cohama/agit.vim'  " git log 見るためのプラグイン
NeoBundle 'https://github.com/idanarye/vim-merginal'
NeoBundle 'https://github.com/tpope/vim-fugitive'
NeoBundle 'https://github.com/gregsexton/gitv.git'

" ---------- NeoBundle required ----------
call neobundle#end()
filetype plugin indent on

" Installation check.
NeoBundleCheck
" ---------- NeoBundle end ---------------


" ----------------------------------------
" common settings
" ----------------------------------------
set fileformat=unix
set encoding=utf-8
set fileencodings=utf-8

" setting syntax color
syntax on
" colorscheme molokai
" colorscheme twilight
" let g:lucius_style = "dark"
" let g:lucius_high_contrast = "0"
" colorscheme lucius
colorscheme hybrid

" show status line
set laststatus=2

" visualize eol of space and tab
set list
set listchars=tab:>_,trail:.

highlight WhitespaceEOL ctermbg=236
au BufWinEnter * let w:m1 = matchadd("WhitespaceEOL", '[ \t]\+$')
au WinEnter * let w:m1 = matchadd("WhitespaceEOL", '[ \t]\+$')

" visualize tab
highlight Tab ctermbg=236
au BufWinEnter * let w:m1 = matchadd("Tab", '\t')
au WinEnter * let w:m1 = matchadd("Tab", '\t')

" visualize 4 space
highlight Whitespaces ctermbg=236
au BufWinEnter * let w:m1 = matchadd("Whitespaces", '    ')
au WinEnter * let w:m1 = matchadd("Whitespaces", '    ')

" visualize double-byte space
highlight ZenkakuSpace cterm=underline ctermbg=203
au BufWinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')
au WinEnter * let w:m3 = matchadd("ZenkakuSpace", '　')

" indent
set autoindent
set tabstop=4
set shiftwidth=4
" if tab to space
set expandtab
autocmd! FileType yaml setlocal tabstop=2 shiftwidth=2
autocmd! FileType html setlocal tabstop=2 shiftwidth=2
autocmd! FileType ruby setlocal tabstop=2 shiftwidth=2

" search
set hlsearch
set incsearch
set ignorecase
set smartcase

" show number of lines
set number

" enable mouse operation
set mouse=nv

" enable clipboard
set clipboard=unnamed,autoselect

" disable default japanise input
" disable default japanise input in insert mode
set iminsert=0
" disable default japanise input in search mode
set imsearch=0

" no swapfile, backupfile
set noswapfile
set nobackup

" set to block the selected range of rectangle visual mode
set virtualedit=block


" set completion on command line mode
" list:full is show completion list, if there are two more completions
set wildmenu wildmode=list:full

" enable backspace on start, end, indent
" start  : enable delete on enter insert mode
" eol    : enable delete end of line
" indent : enable delete indent(autoindent)
set backspace=start,eol,indent

" set vim title
"let &t_ti .= "\e[22;0t"
"let &t_te .= "\e[23;0t"
"set title

" for teraterm
" eliminate the wait time after pressing the ESC key in insert mode
" let &t_SI .= "\e[?7727h"
" let &t_EI .= "\e[?7727l"
" inoremap <special> <Esc>O[ <Esc>
set timeoutlen=1000 ttimeoutlen=0

" support 'GNU Screen'
set ttymouse=xterm2



" tmux用
" tmuxは背景色消去に対応していないので、vimを開くと文字がない部分の背景色が端末の背景色のままになってしまう
" t_ut 端末オプションで、現在の背景色を使って端末の背景をクリアする
set t_ut=



" -------------------------------------------------------------
" end .vimrc
"
" if you want to add your settings, please describe below.
" or please put the vimscript in '.vim/userautoload'
" -------------------------------------------------------------
