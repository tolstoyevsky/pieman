setenv bootargs earlyprintk console=ttyS0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait init=/bin/systemd
setenv fdt_high ffffffff
fatload mmc 0 ${kernel_addr_r} zImage
fatload mmc 0 ${fdt_addr_r} sun8i-h2-plus-orangepi-zero.dtb
fatload mmc 0 ${ramdisk_addr_r} initrd.img
bootz ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}
