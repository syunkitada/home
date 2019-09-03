: set variables of rc files.

cd /d %~dp0
set home=%CD%\
set bash_profile=%home%.bash_profile
set git_prompt=%home%.git-prompt.sh
set git_completion=%home%.git-completion.bash
set gvimrc=%home%.gvimrc
set vimfiles=%home%.vim

set ln_bash_profile=%HOMEPATH%\.bash_profile
set ln_git_prompt=%HOMEPATH%\.git-prompt.sh
set ln_git_completion=%HOMEPATH%\.git-completion.bash
set ln_gvimrc=%HOMEPATH%\.gvimrc
set ln_vimfiles=%HOMEPATH%\vimfiles

: cls is clean display
cls

del %ln_bash_profile%
del %ln_git_prompt%
del %ln_git_completion%
del %ln_gvimrc%
del %ln_vimfiles%

mklink %ln_bash_profile% %bash_profile%
mklink %ln_git_prompt% %git_prompt%
mklink %ln_git_completion% %git_completion%
mklink %ln_gvimrc% %gvimrc%
mklink %ln_vimfiles% %vimfiles%


: @echo off is what don't output command.
@echo off

echo.
echo press any key to end.
pause > nul

