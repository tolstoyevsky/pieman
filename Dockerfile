FROM debian:stretch
MAINTAINER Evgeny Golyshev <eugulixes@gmail.com>

ENV BRANCH master

ENV DEBOOTSTRAP_VER 1.0.91

ENV TERM linux

RUN apt-get update && apt-get install -y \
    dosfstools \
    git \
    gnupg \
    kpartx \
    parted \
    python3-setuptools \
    python3-yaml \
    qemu-user-static \
    rsync \
    uuid-runtime \
    wget \
    whois \
 && touch .dockerenv \
 && mkdir /result \
 && cd \
 && git clone -b $BRANCH --depth 1 https://github.com/tolstoyevsky/pieman.git \
 && cd pieman \
 && git clone https://anonscm.debian.org/git/d-i/debootstrap.git \
 && cd debootstrap && git checkout $DEBOOTSTRAP_VER && cd .. \
 && python3 setup.py install \
 && apt-get purge -y git \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
