: set �ŕϐ����`
: �����ŁA�{����bashrc�Ȃǂ̃p�X���`���Ă���

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

: cls �ŁA�ȑO�̎��s���ʂ�\���������
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

: @echo off �ŁA�ȉ����s�R�}���h��\�������Ȃ�
@echo off

: ���s
echo.
echo press any key to end.

: ���s���~�߂�i�Ȃɂ��L�[�������ƍĊJ���A�I������j
pause > nul

