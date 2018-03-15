#!/bin/sh

set -e

cd /root/pieman && env ./pieman.sh

# Cannot build images in a volume because it causes the following problem on
# some platforms:
# E: Cannot install into target '/build/<project name>/chroot' mounted with
# noexec or nodev
mv /root/pieman/build/*/*.img /result
