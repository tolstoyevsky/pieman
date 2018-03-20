#!/bin/sh

set -e

mkdir qemu-user-static

cd qemu-user-static

wget http://ftp.debian.org/debian/dists/stretch/main/binary-amd64/Packages.xz

xz -d Packages.xz

package=$(grep "Filename: pool/main/q/qemu/qemu-user-static" Packages | awk '{print $2}')

wget http://ftp.debian.org/debian/${package}

ar x $(basename ${package})

tar xJvf data.tar.xz

cp usr/bin/qemu-arm-static /usr/bin

cp usr/bin/qemu-aarch64-static /usr/bin

cd ..

