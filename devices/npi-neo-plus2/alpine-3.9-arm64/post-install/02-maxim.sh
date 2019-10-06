# info "Override hostapd.conf"

# cat << 'EOF' > ${ETC}/hostapd/hostapd.conf
# hw_mode=g
# channel=1
# driver=nl80211

# ssid=friendlyelec-wifiap
# interface=wlan0

# # possible MAC address restriction
# #macaddr_acl=0
# #accept_mac_file=/etc/hostapd.accept
# #deny_mac_file=/etc/hostapd.deny
# #ieee8021x=1    # Use 802.1X authentication

# # encryption
# wpa=2
# wpa_passphrase=123456789
# wpa_key_mgmt=WPA-PSK
# wpa_pairwise=TKIP CCMP
# rsn_pairwise=CCMP
# ctrl_interface=/var/run/hostapd

# # Only root can configure hostapd
# ctrl_interface_group=0
# EOF
