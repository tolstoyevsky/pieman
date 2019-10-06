
# info "Enable brcmfmac module (Wi Fi)"
# echo "brcmfmac" > ${ETC}/modules-load.d/net.conf

# info "Enable snd-soc-simple-card module (Sound)"
# echo "snd-soc-simple-card" > ${ETC}/modules-load.d/snd.conf

# info "Add dbus to default runlevel"
# chroot_exec rc-update add dbus default

# info "Adding modules to default runlevel"
# chroot_exec rc-update add modules default

# info "Adding hostapd to default runlevel"
# chroot_exec rc-update add hostapd default

# info "Switch Wi Fi to access point mode"
# echo "options bcmdhd op_mode=2" > ${ETC}/modprobe.d/bcmdhd.conf

# info "Installing Wi Fi firmware"
# tar -xpf ${SOURCE_DIR}/orig_firmware.tar.gz -C ${R}/lib/firmware