" ----------------------------------------------------------------------------------------------------
" dein、.nvim/rc/*.vim ロード用の設定
" ----------------------------------------------------------------------------------------------------

function! GetNVimVersion()
    redir => s
    silent! version
    redir END
    let nvim_version = matchstr(s, 'NVIM v\zs\d\.\d\ze.*')
    exec 'let nvim_version = ' . nvim_version
    return nvim_version
endfunction

let g:home = expand('~')
if ! len($XDG_CONFIG_HOME)
  echoerr "you should set XDG_CONFIG_HOME. ($ export XDG_CONFIG_HOME=$HOME/.config )"
endif

let g:vim_home = g:home . '/.config/nvim'
let g:dein_dir   = g:vim_home . '/dein'
let g:rc_dir   = g:vim_home . '/rc'

" プラグインが実際にインストールされるディレクトリ
let s:dein_dir = g:home . '/.cache/neovim-dein'
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vim がなければ github から落としてくる
" runtimepathにdeinを追加する
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    if GetNVimVersion() < 0.4
        " MEMO masterだとプラグインがロードできなかった
        execute '!git clone https://github.com/Shougo/dein.vim -b 2.2' s:dein_repo_dir
    else
        execute '!git clone https://github.com/Shougo/dein.vim -b 2.2' s:dein_repo_dir
    endif
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
  let s:toml      = g:dein_dir . '/dein.toml'
  let s:lazy_toml = g:dein_dir . '/dein_lazy.toml'

  " TOML を読み込み、キャッシュしておく
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

" もし、未インストールのプラグインがあればインストールします
if dein#check_install()
  call dein#install()
endif

" vim_starting is true only at start up
if has('vim_starting')
    " autoload my vimscripts
    set runtimepath+=$XDG_CONFIG_HOME/nvim
    runtime! rc/*.vim
    runtime! lua/*.lua
endif

" ----------------------------------------------------------------------------------------------------
" END dein 用の初期設定
" ----------------------------------------------------------------------------------------------------


" ----------------------------------------------------------------------------------------------------
" common settings
" ----------------------------------------------------------------------------------------------------
set fileformat=unix
set encoding=utf-8
set fileencodings=utf-8

" disable beep sound
set vb t_vb=

" setting syntax color
set termguicolors
syntax on
" colorscheme hybrid
colorscheme iceberg
set background=dark

" show status line for lightline
set laststatus=2

" visualize eol of space and tab
set list
set listchars=tab:\ \ ,trail:.

highlight WhitespaceEOL ctermbg=236
au BufWinEnter * let w:m1 = matchadd("WhitespaceEOL", '[ \t]\+$')
au WinEnter * let w:m1 = matchadd("WhitespaceEOL", '[ \t]\+$')

" visualize tab
highlight Tab ctermfg=237 ctermbg=237
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
" set clipboard=unnamed,autoselect
set clipboard=unnamed

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


" tmux用
" tmuxは背景色消去に対応していないので、vimを開くと文字がない部分の背景色が端末の背景色のままになってしまう
" t_ut 端末オプションで、現在の背景色を使って端末の背景をクリアする
set t_ut=


" Enable python3 provider
let g:python3_host_prog = substitute(system('which python3'),"\n","","")


filetype plugin on


" ----------------------------------------------------------------------------------------------------
" END common settings
" ----------------------------------------------------------------------------------------------------
