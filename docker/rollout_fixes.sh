#!/bin/sh

set -e

mkdir packages

#
# qemu-arm-static
#

wget http://ftp.debian.org/debian/dists/stretch/main/binary-amd64/Packages.xz

xz -d Packages.xz

cd packages

package=$(grep "Filename: pool/main/q/qemu/qemu-user-static" ../Packages | awk '{print $2}')

wget http://ftp.debian.org/debian/${package}

ar x $(basename ${package})

tar xJvf data.tar.xz

#
# zlib1g
#

# There are three packages: zlib1g, zlib1g-dbg and zlib1g-dev. Use -m1 to get
# the first one.
package=$(grep -m1 "Filename: pool/main/z/zlib/zlib1g" ../Packages | awk '{print $2}')

wget http://ftp.debian.org/debian/${package}

ar x $(basename ${package})

tar xJvf data.tar.xz

cp usr/bin/qemu-arm-static /usr/bin
cp usr/bin/qemu-aarch64-static /usr/bin
cp lib/x86_64-linux-gnu/libz.so.1.2.8 /usr/glibc-compat/lib/libz.so.1

cd ..

# cleanup
rm    Packages
rm -r packages

