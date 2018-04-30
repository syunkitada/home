" Requirements
" Vim-7.4, git

if len($H)
  let g:home = expand('$H')
  set runtimepath-=~/.vim
  set runtimepath+=$H/.vim
else
  let g:home = expand('~')
endif

let g:vim_home = g:home . '/.vim'
let g:rc_dir   = g:vim_home . '/rc'

" vimrc に以下のように追記

" プラグインが実際にインストールされるディレクトリ
let s:dein_dir = g:home . '/.cache/dein'
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vim がなければ github から落としてくる
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  if has("gui_running") && has('win32')
    execute 'set runtimepath^=' . s:dein_repo_dir
  else
    execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
  endif
endif

" 設定開始
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " プラグインリストを収めた TOML ファイル
  let s:toml      = g:rc_dir . '/dein.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  " TOML を読み込み、キャッシュしておく
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

" もし、未インストールものものがあったらインストール
if dein#check_install()
  call dein#install()
endif

" vim_starting is true only at start up
if has('vim_starting')
    " autoload my vimscripts
    runtime! userautoload/*.vim
endif


" ----------------------------------------
" common settings
" ----------------------------------------
set fileformat=unix
set encoding=utf-8
set fileencodings=utf-8

" disable beep sound
set vb t_vb=

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
autocmd! FileType make setlocal noexpandtab

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


" For makefile
let _currentfile=expand("%:r")
if _currentfile == 'Makefile'
  set noexpandtab
endif


" For golang
" vim-go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1


set rtp+=~/.fzf


" -------------------------------------------------------------
" end .vimrc
"
" if you want to add your settings, please describe below.
" or please put the vimscript in '.vim/userautoload'
" -------------------------------------------------------------
