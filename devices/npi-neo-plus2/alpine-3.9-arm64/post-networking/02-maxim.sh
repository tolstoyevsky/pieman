
info "Enable brcmfmac module (Wi Fi)"
echo "brcmfmac" > ${ETC}/modules-load.d/net.conf

info "Enable snd-soc-simple-card module (Sound)"
echo "snd-soc-simple-card" > ${ETC}/modules-load.d/snd.conf

info "Add dbus to default runlevel"
chroot_exec rc-update add dbus default

info "Adding modules to default runlevel"
chroot_exec rc-update add modules default

info "Adding hostapd to default runlevel"
chroot_exec rc-update add hostapd default

info "Switch Wi Fi to access point mode"
echo "options bcmdhd op_mode=2" > ${ETC}/modprobe.d/bcmdhd.conf

info "Install Wi Fi firmware"
tar -xpf ${SOURCE_DIR}/orig_firmware.tar.gz -C ${R}/lib/firmware

info "Override hostapd"
cat << 'EOF' > ${ETC}/hostapd/hostapd.conf
hw_mode=g
channel=1
driver=nl80211

ssid=friendlyelec-wifiap
interface=wlan0

# possible MAC address restriction
#macaddr_acl=0
#accept_mac_file=/etc/hostapd.accept
#deny_mac_file=/etc/hostapd.deny
#ieee8021x=1    # Use 802.1X authentication

# encryption
wpa=2
wpa_passphrase=123456789
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=CCMP
ctrl_interface=/var/run/hostapd

# Only root can configure hostapd
ctrl_interface_group=0
EOF

info "Override networking"
cat << 'EOF' > ${ETC}/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

auto wlan0
allow-hotplug wlan0

iface wlan0 inet static
address 192.168.8.1
netmask 255.255.255.0
EOF
