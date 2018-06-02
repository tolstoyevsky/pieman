FROM alpine:3.7

ENV BRANCH master

ENV DEBOOTSTRAP_VER 1.0.91

ENV TERM linux

ARG VCS_REF

LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/tolstoyevsky/pieman"

COPY rollout_fixes.sh /usr/bin/rollout_fixes.sh

RUN touch .dockerenv \
 && apk --update add \
    bash \
    # for ar
    binutils \
    dosfstools \
    dpkg \
    # for tune2fs
    e2fsprogs-extra \
    git \
    gnupg \
    # for tput
    ncurses \
    parted \
    # for pkgdetails
    perl \
    py3-yaml \
    rsync \
    # for uuidgen
    util-linux \
    # debootstrap needs GNU tar instead of tar from Busybox
    tar \
    wget \
    whois \
    xz \
 && mkdir /result \
 && /usr/bin/rollout_fixes.sh \
 && rm -r qemu-user-static \
 && cd \
 && git clone -b $BRANCH --depth 1 https://github.com/tolstoyevsky/pieman.git \
 && cd pieman \
 && git clone https://anonscm.debian.org/git/d-i/debootstrap.git \
 && cd debootstrap && git checkout $DEBOOTSTRAP_VER && cd .. \
 && pip3 install pieman \
 && apk del git \
 && rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

