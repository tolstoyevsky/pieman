set -e

check_if_variable_is_set R SOURCE_DIR

# There are two problems related to the flash-kernel package during the kernel
# installation.
#
# 1) /usr/share/initramfs-tools/hooks/flash_kernel_set_root from flash-kernel
#    shows the following message and pauses the kernel installation.
#    Warning: root device  does not exist
#    Press Ctrl-C to abort build, or Enter to continue
#
# 2) flash-kernel can't check the platform the system is running on because
#    flash kernel doesn't provide for running in a chroot environment.
#
# To workaround it, install flash-kernel and patch it.

install_packages flash-kernel patch

cp "${SOURCE_DIR}"/fix-kernel-installation-in-chroot.patch "${R}"

chroot_exec_sh "patch -p0 < fix-kernel-installation-in-chroot.patch"

# Clean up

rm "${R}"/fix-kernel-installation-in-chroot.patch

purge_packages patch
