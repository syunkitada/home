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
" unite-ver.6.0だとunite-outlineが動作しないのでver.5.1を利用する: 2014/9/27
NeoBundleLazy 'git://github.com/Shougo/unite.vim', 'ver.5.1', {
    \'autoload' : {'commands': ['Unite', 'UniteWithBufferDir']}}
NeoBundleLazy 'git://github.com/h1mesuke/unite-outline', {
    \'autoload': {'unit_sources': ['outline']}}
" vimfiler-ver.4.1がファイル作成時にエラー(unit依存?)を出すのでver.4.0を利用する: 2014/11/15
NeoBundleLazy 'git://github.com/Shougo/vimfiler.vim', 'ver.4.0', {
    \'autoload': {'commands': ['VimFiler']}}
NeoBundleLazy 'git://github.com/Shougo/neocomplcache', {
    \'autoload': {'insert': 1}}
NeoBundleLazy 'git://github.com/Shougo/vimshell', {
    \'autoload': {'commands': ['VimShell', 'VimShellCreate', 'VimShellPop', 'VimShellTab']}}
NeoBundle 'git://github.com/Shougo/neomru.vim'
NeoBundle 'git://github.com/Shougo/vimproc', {
    \'build' : {
    \        'windows' : 'make -f make_mingw32.mak',
    \        'cygwin' : 'make -f make_cygwin.mak',
    \        'mac' : 'make -f make_mac.mak',
    \        'unix' : 'make -f make_unix.mak',
    \    },
    \}
NeoBundle 'git://github.com/tacroe/unite-mark'
NeoBundle 'git://github.com/vim-scripts/tComment'
NeoBundle 'git://github.com/vim-scripts/sudo.vim'
NeoBundle 'git://github.com/vim-scripts/vcscommand.vim'
NeoBundle 'git://github.com/kshenoy/vim-signature'
NeoBundle 'git://github.com/Lokaltog/vim-easymotion'
NeoBundle 'git://github.com/thinca/vim-quickrun'
NeoBundle 'git://github.com/gregsexton/gitv.git'
NeoBundleLazy 'git://github.com/mattn/emmet-vim.git', {
    \'autoload': {'filetypes': ['html']}}
NeoBundle 'git://github.com/tpope/vim-surround.git'
NeoBundle 'git://github.com/scrooloose/syntastic.git'
NeoBundleLazy 'git://github.com/vim-scripts/TaskList.vim', {
    \ 'autoload': {'mappings': ['<Plug>TaskList']}}


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
colorscheme molokai

" visualize tab
highlight Tab ctermbg=236
au BufWinEnter * let w:m1 = matchadd("Tab", '\t')
au WinEnter * let w:m1 = matchadd("Tab", '\t')

" visualize 4 space
highlight Whitespaces ctermbg=234
au BufWinEnter * let w:m1 = matchadd("Whitespaces", '    ')
au WinEnter * let w:m1 = matchadd("Whitespaces", '    ')

" visualize eol of space and tab
highlight WhitespaceEOL ctermbg=240
au BufWinEnter * let w:m1 = matchadd("WhitespaceEOL", '[ \t]\+$')
au WinEnter * let w:m1 = matchadd("WhitespaceEOL", '[ \t]\+$')

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

" search
set hlsearch
set incsearch
set ignorecase
set smartcase

" show number of lines
set number

" enable mouse operation
set mouse=nv

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
