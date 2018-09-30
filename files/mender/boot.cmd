fdt addr ${fdt_addr} && fdt get value bootargs /chosen bootargs
run mender_setup
mmc dev ${mender_uboot_dev}
load ${mender_uboot_root} ${kernel_addr_r} /boot/zImage
bootz ${kernel_addr_r} - ${fdt_addr}
run mender_try_to_recover
