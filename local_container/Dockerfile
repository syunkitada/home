FROM rockylinux:9

ARG GO_VERSION=1.24.5

RUN dnf install -y \
    systemd sudo man vim findutils procps-ng \
    git wget make

# Install Go
# https://go.dev/dl/
RUN	curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    | gunzip | sudo tar x -C /usr/local

# Install Astral UV
# https://docs.astral.sh/uv/getting-started/installation/
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Remove unused systemd services
RUN ls /lib/systemd/system/*.wants/* | grep -v journald | xargs rm -rf

ENV PATH=$HOME/.local/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["/usr/sbin/init"]