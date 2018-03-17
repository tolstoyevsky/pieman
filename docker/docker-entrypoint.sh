#!/bin/bash

set -e

cd /root/pieman && env ./pieman.sh

# Cannot build images in a volume because it causes the following problem on
# some platforms:
# E: Cannot install into target '/build/<project name>/chroot' mounted with
# noexec or nodev
mv $(ls /root/pieman/build/*/*.img{.bz2,.gz,.xz,} 2> /dev/null) /result
