#!/bin/bash

set -ex

# install tmux
TMUX_VERSION=3.3
if [ ! -e ~/.local/bin/tmux ]; then
	cd /tmp || exit 1
	curl -kLO https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
	tar -zxvf tmux-${TMUX_VERSION}.tar.gz
	cd tmux-${TMUX_VERSION} || exit 1
	./configure --prefix="${HOME}/.local"
	make
	sudo make install
	cd ../
	rm -rf tmux-*
fi
