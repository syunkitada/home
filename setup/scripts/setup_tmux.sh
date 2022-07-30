

# install tmux
if [ ! -e /usr/loca/bin/tmux ]; then
    curl -kLO https://github.com/tmux/tmux/releases/download/2.8/tmux-2.8.tar.gz
    tar -zxvf tmux-2.8.tar.gz
    cd tmux-2.8
    ./configure
    make
    sudo make install
    cd ../
    rm -rf tmux-*
fi
