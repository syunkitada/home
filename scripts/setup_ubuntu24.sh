#!/bin/bash

set -e
. confrc

function _install() {
    for pkg in "$@"; do
        dpkg -s "$pkg" || sudo apt install -y "$pkg"
    done
}

function setup_dev_tools() {
    # 汎用ツール類のインストール
    sudo apt update -y
    _install curl git zsh build-essential ncurses-dev snapd

    # pythonとその関連パッケージのインストール
    _install python3 python3-venv python3-dev python3-pip

    # node
    rm -f ~/.npmrc
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm install 24

    # https://github.com/watchexec/watchexec
    # ファイルの変更検知して自動でプロセス再起動してくれる
    if ! type watchexec; then
        WATCHEXEC_VERSION=${WATCHEXEC_VERSION:-1.21.1}
        cd /tmp || exit 1
        wget "https://github.com/watchexec/watchexec/releases/download/v${WATCHEXEC_VERSION}/watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.deb"
        sudo dpkg -i "/tmp/watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.deb"
        rm "/tmp/watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.deb"
        cd - || exit 1
    fi
}

# install tmux
function setup_tmux() {
    _install tmux
}

function setup_dev_clang() {
    _install clang clangd clang-format
}

# ファイル検索ツール
# _install silversearcher-ag

# razygit
# https://github.com/jesseduffield/lazygit
# LAZYGIT_VERSION=0.35
# if [ "$(lazygit --version | sed -r 's/^.*version=([0-9]+\.[0-9]+), .*$/\1/')" != "${LAZYGIT_VERSION}" ]; then
# 	curl -Lo lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v0.35/lazygit_0.35_Linux_x86_64.tar.gz
# 	tar -xzf lazygit.tar.gz -C ~/.local/bin lazygit
# 	rm lazygit.tar.gz
# fi

function help() {
    cat <<EOS
setup_base_tools
setup_dev_tools
setup_tmux
setup_dev_clang
EOS
}

if [ $# != 0 ]; then
    "${@}"
fi
