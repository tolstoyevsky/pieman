setenv bootargs earlyprintk console=ttyS0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait init=/sbin/init
setenv fdt_high ffffffff
fatload mmc 0 ${kernel_addr_r} zImage
fatload mmc 0 ${fdt_addr_r} sun50i-h5-nanopi-neo-plus2.dtb
fatload mmc 0 ${ramdisk_addr_r} initramfs-vanilla
booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}
