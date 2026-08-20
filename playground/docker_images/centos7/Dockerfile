FROM centos:centos7.9.2009

RUN useradd playground && \
    gpasswd -a playground playground && \
    echo "playground ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENTRYPOINT [ "sleep", "36000" ]
