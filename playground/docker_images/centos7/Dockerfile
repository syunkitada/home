FROM centos:centos7.9.2009

RUN yum install -y sudo make openssh-server && \
    mkdir -p /var/run/sshd && \
    sshd-keygen && \
    chmod 600 /etc/ssh/ssh_*_key && \
    useradd playground && \
    gpasswd -a playground playground && \
    echo "playground ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENTRYPOINT [ "sleep", "36000" ]
