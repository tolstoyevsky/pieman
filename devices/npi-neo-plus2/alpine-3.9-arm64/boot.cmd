# Recompile with:
# mkimage -C none -A arm -T script -d boot.cmd boot.scr

setenv ramdisk rootfs.cpio.gz
setenv kernel Image

setenv env_addr 0x45000000
setenv kernel_addr 0x46000000
setenv ramdisk_addr 0x47000000
setenv dtb_addr 0x48000000
setenv fdtovaddr 0x49000000

fatload mmc 0 ${kernel_addr} ${kernel}
fatload mmc 0 ${ramdisk_addr} ${ramdisk}
if test $board = nanopi-neo2-v1.1; then 
    fatload mmc 0 ${dtb_addr} sun50i-h5-nanopi-neo2.dtb
else
    fatload mmc 0 ${dtb_addr} sun50i-h5-${board}.dtb
fi
fdt addr ${dtb_addr}

# setup NEO2-V1.1 with gpio-dvfs overlay
if test $board = nanopi-neo2-v1.1; then
    fatload mmc 0 ${fdtovaddr} overlays/sun50i-h5-gpio-dvfs-overlay.dtb
    fdt resize 8192
    fdt apply ${fdtovaddr}
fi

# setup MAC address 
fdt set ethernet0 local-mac-address ${mac_node}

# setup boot_device
fdt set mmc${boot_mmc} boot_device <1>

setenv fbcon map:0
setenv bootargs console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait panic=10 ${extra} fsck.mode=skip fbcon=${fbcon} init=/sbin/init
booti ${kernel_addr} ${ramdisk_addr}:500000 ${dtb_addr}
