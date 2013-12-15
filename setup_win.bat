: set で変数を定義
: ここで、本来のbashrcなどのパスを定義しておく

set home=%CD%\
set bashrc=%home%.bashrc
set vimrc=%home%.vimrc
set vrapperrc=%home%.vrapperrc
set gvimrc=%home%.gvimrc
set vim=%home%.vim
set vimfiles=%home%.vim

set ln_bashrc=%HOMEPATH%\.bashrc
set ln_vimrc=%HOMEPATH%\.vimrc
set ln_vrapperrc=%HOMEPATH%\.vrapperrc
set ln_gvimrc=%HOMEPATH%\.gvimrc
set ln_vim=%HOMEPATH%\.vim
set ln_vimfiles=%HOMEPATH%\vimfiles

: cls で、以前の実行結果を表示から消す
cls

del %ln_bashrc%
del %ln_vimrc%
del %ln_gvimrc%
del %ln_vim%
del %ln_vimfiles%
del %ln_vrapperrc%

mklink %ln_bashrc% %bashrc%
mklink %ln_vimrc% %vimrc%
mklink %ln_gvimrc% %gvimrc%
mklink %ln_vim% %vim%
mklink %ln_vimfiles% %vimfiles%
mklink %ln_vrapperrc% %vrapperrc%

: @echo off で、以下実行コマンドを表示させない
@echo off

: 改行
echo.
echo press any key to end.

: 実行を止める（なにかキーを押すと再開し、終了する）
pause > nul

