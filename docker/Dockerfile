FROM alpine:3.10

ENV BRANCH master

ENV PYTHONPATH "/root/pieman/pieman"

ENV TERM linux

ENV TOOLSET_VER v4-amy

ARG VCS_REF

LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/tolstoyevsky/pieman"

COPY rollout_fixes.sh /usr/bin/rollout_fixes.sh

RUN touch .dockerenv \
 && apk --update add \
    bash \
    # for ar
    binutils \
    # u-boot-sunxi-with-spl.bin needs to be written to images by dd from
    # GNU Coreutils instead of dd from Busybox
    coreutils \
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
    rsync \
    # for losetup
    util-linux \
    # debootstrap needs GNU tar instead of tar from Busybox
    tar \
    xz \
    # The following packages are necessary for building 2 different versions of
    # U-Boot (vanilla and Mender flavour) and Mender client
    bc \
    bison \
    ca-certificates \
    dtc \
    flex \
    gcc \
    go \
    make \
    musl-dev \
    python2-dev \
    python3 \
    swig \
 # Provide a compatibility layer for the cross-compiler which is linked
 # against glibc.
 && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk \
 && apk add glibc-2.28-r0.apk \
 \
 && mkdir /result \
 && /usr/bin/rollout_fixes.sh \
 && cd \
 && git clone -b $BRANCH --depth 1 https://github.com/tolstoyevsky/pieman.git \
 && cd pieman \
 && pip3 install -r "${PYTHONPATH}"/requirements.txt \
 && env PREPARE_ONLY_TOOLSET=true ./pieman.sh \
 && cp toolset/$TOOLSET_VER/qemu-user-static/qemu-arm-static /usr/bin \
 && cp toolset/$TOOLSET_VER/qemu-user-static/qemu-aarch64-static /usr/bin \
 && apk del \
    bc \
    bison \
    ca-certificates \
    dtc \
    flex \
    gcc \
    go \
    make \
    musl-dev \
    python2-dev \
    swig \
 && rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
