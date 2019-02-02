" disable autoindent on paste
if &term =~ "xterm"
	let &t_ti .= "\e[?2004h"
	let &t_te .= "\e[?2004l"
	let &pastetoggle = "\e[201~"

	function XTermPasteBegin(ret)
		set paste
		return a:ret
	endfunction

	noremap <special> <expr> <Esc>[200~ XTermPasteBegin("0i")
	inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
	cnoremap <special> <Esc>[200~ <nop>
	cnoremap <special> <Esc>[201~ <nop>
endif

" yank register to clipboard of teraterm
command! CopyToTeraterm let $vim_clipboard = @" | !echo "$vim_clipboard" | copy_to_teraterm

" vim +clipboard
" for gui
set guioptions+=a
" for cui
" set clipboard+=autoselect
" mouse for clipboard
nnoremap <RightMouse> "*p
inoremap <RightMouse> <Esc>"*p
nnoremap <MiddleMouse> GVgg
inoremap <MiddleMouse> <Esc>GVgg
vnoremap <MiddleMouse> <Esc>GVgg
