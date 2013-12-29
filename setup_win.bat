: set variables of rc files.

set home=%CD%\
set bashrc=%home%.bashrc
set vimrc=%home%.vimrc
set vrapperrc=%home%.vrapperrc
set gvimrc=%home%.gvimrc
set vim=%home%.vim
set vimfiles=%home%.vim
set git_prompt=%home%.git-prompt.sh
set git_completion=%home%.git-completion.bash

set ln_bashrc=%HOMEPATH%\.bash_profile
set ln_vimrc=%HOMEPATH%\.vimrc
set ln_vrapperrc=%HOMEPATH%\.vrapperrc
set ln_gvimrc=%HOMEPATH%\.gvimrc
set ln_vim=%HOMEPATH%\.vim
set ln_vimfiles=%HOMEPATH%\vimfiles
set ln_git_prompt=%HOMEPATH%\.git-prompt.sh
set ln_git_completion=%HOMEPATH%\.git-completion.bash

: cls is clean display
cls

del %ln_bashrc%
del %ln_vimrc%
del %ln_gvimrc%
del %ln_vim%
del %ln_vimfiles%
del %ln_vrapperrc%
del %ln_git_prompt%
del %ln_git_completion%

mklink %ln_bashrc% %bashrc%
mklink %ln_vimrc% %vimrc%
mklink %ln_gvimrc% %gvimrc%
mklink %ln_vim% %vim%
mklink %ln_vimfiles% %vimfiles%
mklink %ln_vrapperrc% %vrapperrc%
mklink %ln_git_prompt% %git_prompt%
mklink %ln_git_completion% %git_completion%


: @echo off is what don't output command.
@echo off

echo.
echo press any key to end.
pause > nul

