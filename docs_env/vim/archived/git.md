# git 関連のプラグイン

- git 操作は vim にプラグイン入れてやるよりも、lazygit を使うことにしました

## vim-fugitive

```
# basic plugin
[[plugins]]
repo = 'https://github.com/tpope/vim-fugitive'
```

```
" vim-fugitive
" gitの基本機能
" [KEYBIND] key=_ga; tags=git,edit; action=git addします;
nmap [git]a :Gwrite<CR>
" [KEYBIND] key=_gc; tags=git,edit; action=git commitします;
nmap [git]c :Gcommit -v<CR>
" [KEYBIND] key=_gs; tags=git,show; action=git statusします;
nmap [git]s :Gstatus<CR>
" [KEYBIND] key=_gb; tags=git,show; action=git blameします;
nmap [git]b :Gblame<CR>
" [KEYBIND] key=_gd; tags=git,show; action=git diffします;
nmap [git]d :Gdiff<CR>
" [KEYBIND] key=_gp; tags=git,update; action=git pullします;
nmap [git]p :Gpull<CR>
" [KEYBIND] key=_gu; tags=git,update; action=git pushします;
nmap [git]P :Gpush<CR>
```

## agit

```
# agit
# git log を閲覧用のビューアです
[[plugins]]
repo = 'https://github.com/cohama/agit.vim'
```

```
" [KEYBIND] key=_gl; tags=git,show; action=git logを表示します;
nmap [git]l :Agit<CR>
```
