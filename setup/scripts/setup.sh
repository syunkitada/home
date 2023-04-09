#!/bin/bash

# セットアップオプション
SETUP_RUST=${SETUP_RUST:-false}

# OS非依存の汎用の関数ライブラリを読み込みます
source setup_common.sh

# OS依存の関数ライブラリを読み込みます
OS_NAME=$(grep "^NAME=" /etc/os-release | awk -F '=' '{print $2}' | sed -e 's/"//g' | awk -F ' ' '{print $1}')
OS_VERSION=$(grep "^VERSION_ID=" /etc/os-release | awk -F '=' '{print $2}' | sed -e 's/"//g' | awk -F '.' '{print $1}')

echo "OS_NAME=$OS_NAME, OS_VERSION=$OS_VERSION"
if [ "$OS_NAME" = "Rocky" -a "$OS_VERSION" = "8" ]; then
	echo "load ./setup_rocky8.sh"
	source ./setup_rocky8.sh
fi
if [ "$OS_NAME" = "Ubuntu" -a "$OS_VERSION" = "22" ]; then
	echo "load ./setup_ubuntu20.sh"
	source ./setup_ubuntu20.sh
fi

set -ex

# dot_filesを配置します
setup_base_tools
./link_dotfiles.sh

# 最低限の環境変数を読み込みます
source ~/.envrc

setup_init
setup_dev_tools
setup_nvim
setup_fzf
setup_dev_python
setup_dev_shell
setup_dev_web
setup_dev_go
if "$SETUP_RUST"; then
	setup_dev_rust
fi
