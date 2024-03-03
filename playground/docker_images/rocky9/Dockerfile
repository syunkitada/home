FROM rockylinux:9

RUN yum install -y sudo make openssh-server && \
    useradd playground && \
    gpasswd -a playground playground && \
    echo "playground ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENTRYPOINT [ "sleep", "36000" ]
