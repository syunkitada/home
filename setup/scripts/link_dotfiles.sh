#!/bin/sh -xe

# 設定ファイル配置用のスクリプトです
# dotfiles 内のファイルのシンボリックリンクを ~/ に作成します
# dotconfig 内のファイルのシンボリックリンクを ~/.config に作成します

export ROOT=${HOME}/home/
cd $ROOT


XDG_CONFIG_HOME=${HOME}/.config
mkdir -p ${XDG_CONFIG_HOME}

for file in `find dotfiles -name '.*' -printf "%f\n"`
do
    src=${ROOT}/dotfiles/${file}
    dst=${HOME}/${file}
    rm -f $dst
    ln -s $src $dst
done

for file in `ls dotconfig`
do
    src=${ROOT}/dotconfig/${file}
    dst=${HOME}/.config/${file}
    rm -f $dst
    ln -s $src $dst
done
