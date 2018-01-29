set -e

check_if_variable_is_set R

# There are some problems with creating a base system of Ubuntu 17.10.
# The original message copied from /debootstrap/debootstrap.log:
#
# Errors were encountered while processing:
#  /var/cache/apt/archives/bash_4.4-5ubuntu1_arm64.deb
# dpkg: regarding .../base-files_9.6ubuntu102_arm64.deb containing base-files, pre-dependency problem:
#  base-files pre-depends on awk
#   mawk provides awk but is unpacked but not configured.
#
# To workaround it remove bash from the required list.

sed -i "s/ bash//" ${R}/debootstrap/required
