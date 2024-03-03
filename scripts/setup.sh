#!/bin/bash -e

cd "$(dirname "$0")" || exit 1

. confrc

# OS非依存の汎用の関数ライブラリを読み込みます
source setup_common.sh

# OS依存の関数ライブラリを読み込みます
OS_NAME=$(grep "^NAME=" /etc/os-release | awk -F '=' '{print $2}' | sed -e 's/"//g' | awk -F ' ' '{print $1}')
OS_VERSION=$(grep "^VERSION_ID=" /etc/os-release | awk -F '=' '{print $2}' | sed -e 's/"//g' | awk -F '.' '{print $1}')

echo "OS_NAME=$OS_NAME, OS_VERSION=$OS_VERSION"
if [ "$OS_NAME" = "CentOS" ] && [ "$OS_VERSION" = "7" ]; then
	echo "load ./setup_centos7.sh"
	source ./setup_centos7.sh
elif [ "$OS_NAME" = "Rocky" ] && [ "$OS_VERSION" = "8" ]; then
	echo "load ./setup_rocky8.sh"
	source ./setup_rocky8.sh
elif [ "$OS_NAME" = "Rocky" ] && [ "$OS_VERSION" = "9" ]; then
	echo "load ./setup_rocky9.sh"
	source ./setup_rocky9.sh
elif [ "$OS_NAME" = "Ubuntu" ] && [ "$OS_VERSION" = "22" ]; then
	echo "load ./setup_ubuntu22.sh"
	source ./setup_ubuntu22.sh
else
	echo "Unsupported OS: ${OS_NAME} ${OS_VERSION}"
	exit 1
fi

# 拡張用のライブラリを読み込みます
source setup_common_ex.sh

set -ex

# dot_filesを配置します
setup_base_tools
setup_dotfiles

# 最低限の環境変数を読み込みます
#shellcheck disable=SC1090
source ~/.envrc

setup_init
setup_dev_tools
setup_nvim
setup_tmux
setup_fzf
setup_dev_python
setup_dev_shell
setup_dev_web
setup_dev_go
setup_dev_clang
if "$SETUP_RUST"; then
	setup_dev_rust
fi

echo "
----------------------------------------------------------------------------------------------------
Setup Complete!
----------------------------------------------------------------------------------------------------
"
