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
" initialize neobundle
call neobundle#rc(expand('~/.vim/bundle/'))

" plugins
NeoBundle 'git://github.com/Shougo/unite.vim'
NeoBundle 'git://github.com/Shougo/vimfiler.vim'
NeoBundle 'git://github.com/Shougo/neocomplcache'
NeoBundle 'git://github.com/Shougo/vimshell'
NeoBundle 'git://github.com/Shougo/neomru.vim'
NeoBundle 'git://github.com/Shougo/vimproc', {
      \ 'build' : {
      \     'windows' : 'make -f make_mingw32.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }
NeoBundle 'git://github.com/h1mesuke/unite-outline'
NeoBundle 'git://github.com/vim-scripts/tComment'
NeoBundle 'git://github.com/vim-scripts/sudo.vim'
NeoBundle 'git://github.com/Lokaltog/vim-easymotion'
NeoBundle 'git://github.com/goldfeld/vim-seek'
NeoBundle 'git://github.com/thinca/vim-quickrun'
NeoBundle 'git://github.com/gregsexton/gitv.git'
NeoBundle 'git://github.com/mhinz/vim-startify.git'
NeoBundle 'git://github.com/mattn/emmet-vim.git'
NeoBundle 'git://github.com/tpope/vim-surround.git'
NeoBundle 'git://github.com/tpope/vim-fugitive.git'
" ---------- NeoBundle ----------


" ----------------------------------------
" common settings
" ----------------------------------------
set fileformat=unix
set encoding=utf-8
set fileencodings=utf-8

" setting syntax color
syntax on
colorscheme molokai

" indent
set autoindent
set tabstop=4
set shiftwidth=4
" if tab to space
" set expandtab

" search
set hlsearch
set incsearch
set ignorecase

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
let &t_ti .= "\e[22;0t"
let &t_te .= "\e[23;0t"
set title

" for teraterm
if &term =~ "xterm256"
	" eliminate the wait time after pressing the ESC key in insert mode
	let &t_SI .= "\e[?7727h"
	let &t_EI .= "\e[?7727l"
	inoremap <special> <Esc>O[ <Esc>
endif

" support 'GNU Screen'
set ttymouse=xterm2


" ---------- NeoBundle required ----------
filetype plugin indent on
" Installation check.
NeoBundleCheck
" ---------- NeoBundle end ---------------


" -------------------------------------------------------------
" end .vimrc
"
" if you want to add your settings, please describe below.
" or please put the vimscript in '.vim/userautoload'
" -------------------------------------------------------------

