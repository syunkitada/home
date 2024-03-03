FROM ubuntu:22.04

RUN apt update && \
    apt install -y openssh-server sudo make && \
    mkdir /var/run/sshd && \
    useradd playground && \
    gpasswd -a playground playground && \
    mkdir -p /home/playground && \
    chown -R playground:playground /home/playground && \
    echo "playground ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENTRYPOINT [ "/usr/sbin/sshd", "-D" ]
