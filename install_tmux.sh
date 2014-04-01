#!/bin/sh

sudo yum install ncurses ncurses-devel -y

wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
tar xvzf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure
make
make install
cd ../
rm -rf libevent*

echo /usr/local/lib > /etc/ld.so.conf.d/libevent.conf
sudo ldconfig

wget http://downloads.sourceforge.net/tmux/tmux-1.9a.tar.gz
tar xvzf tmux-1.9a.tar.gz
cd tmux-1.9a
./configure
make
sudo make install
cd ../
rm -rf tmux*
