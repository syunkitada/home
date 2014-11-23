: set variables of rc files.

cd /d %~dp0
set home=%CD%\
set bash_profile=%home%.bash_profile
set zshrc=%home%.zshrc
set git_prompt=%home%.git-prompt.sh
set git_completion=%home%.git-completion.bash
set screenrc=%home%.screenrc
set tmuxconf=%home%.tmux.conf
set vimrc=%home%.vimrc
set gvimrc=%home%.gvimrc
set vimshrc=%home%.vimshrc
set vim=%home%.vim
set vimfiles=%home%.vim
set vrapperrc=%home%.vrapperrc

set ln_bash_profile=%HOMEPATH%\.bash_profile
set ln_zshrc=%HOMEPATH%\.zshrc
set ln_git_prompt=%HOMEPATH%\.git-prompt.sh
set ln_git_completion=%HOMEPATH%\.git-completion.bash
set ln_screenrc=%HOMEPATH%\.screenrc
set ln_tmuxconf=%HOMEPATH%\.tmux.conf
set ln_vimrc=%HOMEPATH%\.vimrc
set ln_gvimrc=%HOMEPATH%\.gvimrc
set ln_vimshrc=%HOMEPATH%\.vimshrc
set ln_vim=%HOMEPATH%\.vim
set ln_vimfiles=%HOMEPATH%\vimfiles
set ln_vrapperrc=%HOMEPATH%\.vrapperrc

: cls is clean display
cls

del %ln_bash_profile%
del %ln_zshrc%
del %ln_git_prompt%
del %ln_git_completion%
del %ln_screenrc%
del %ln_tmuxconf%
del %ln_vimrc%
del %ln_gvimrc%
del %ln_vimshrc%
del %ln_vim%
del %ln_vimfiles%
del %ln_vrapperrc%

mklink %ln_bash_profile% %bash_profile%
mklink %ln_zshrc% %zshrc%
mklink %ln_git_prompt% %git_prompt%
mklink %ln_git_completion% %git_completion%
mklink %ln_screenrc% %screenrc%
mklink %ln_tmuxconf% %tmuxconf%
mklink %ln_vimrc% %vimrc%
mklink %ln_gvimrc% %gvimrc%
mklink %ln_vimshrc% %vimshrc%
mklink %ln_vim% %vim%
mklink %ln_vimfiles% %vimfiles%
mklink %ln_vrapperrc% %vrapperrc%


: @echo off is what don't output command.
@echo off

echo.
echo press any key to end.
pause > nul

