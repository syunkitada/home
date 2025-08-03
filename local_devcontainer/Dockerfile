FROM rockylinux:9

COPY ./docs /root/home/docs
COPY ./scripts /root/home/scripts
COPY ./Makefile /root/home/Makefile
COPY ./xdgconfig /root/home/xdgconfig
COPY ./dotfiles /root/home/dotfiles

RUN dnf install -y \
    systemd sudo man vim findutils procps-ng \
    git wget make diffutils

RUN cd /root/home && make

# Remove unused systemd services
RUN ls /lib/systemd/system/*.wants/* | grep -v journald | xargs rm -rf

ENV PATH=$HOME/.local/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["/usr/sbin/init"]