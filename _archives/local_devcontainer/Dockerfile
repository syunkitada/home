FROM rockylinux:9

COPY . /root/home

RUN dnf install -y \
    systemd sudo man vim findutils procps-ng \
    git wget make diffutils \
    iproute

RUN cd /root/home && make

RUN dnf -y install dnf-plugins-core && \
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Remove unused systemd services
RUN ls /lib/systemd/system/*.wants/* | grep -v journald | xargs rm -rf

ENV PATH=$HOME/.local/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["/usr/sbin/init"]