# Copyright (C) 2017 Evgeny Golyshev <eugulixes@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

check_if_variable_is_set \
    ENABLE_CUSTOM_DNS \
    ENABLE_BASIC_YANDEX_DNS \
    ENABLE_FAMILY_YANDEX_DNS \
    ENABLE_GOOGLE_DNS \
    ETC

dns_addr1=""
dns_addr2=""
dns_is_set=false

if ${ENABLE_GOOGLE_DNS}; then
    dns_addr1="8.8.8.8"
    dns_addr2="8.8.4.4"
    dns_is_set=true
elif ${ENABLE_BASIC_YANDEX_DNS}; then
    dns_addr1="77.88.8.8"
    dns_addr2="77.88.8.1"
    dns_is_set=true
elif ${ENABLE_FAMILY_YANDEX_DNS}; then
    dns_addr1="77.88.8.7"
    dns_addr2="77.88.8.3"
    dns_is_set=true
elif [[ -n ${ENABLE_CUSTOM_DNS} ]]; then
    dns_addr1="${ENABLE_CUSTOM_DNS}"
    dns_is_set=true
fi

if is_alpine; then
    mkdir "${ETC}/udhcpc"
    addrs=$(echo "${dns_addr1} ${dns_addr2}" | xargs)
    echo -e "dns=\"${addrs}\"" > "${ETC}/udhcpc/udhcpc.conf"
elif is_debian_based; then
    for i in ${dns_addr1} ${dns_addr2}; do
        echo "nameserver ${i}" >> "${ETC}"/resolvconf/resolv.conf.d/base
    done

    if ${dns_is_set}; then
        chroot_exec resolvconf -u
    fi
fi

install_readonly files/etc/hostname.template "${ETC}"/hostname
sed -i "s/{HOSTNAME}/${HOST_NAME}/" "${ETC}/hostname"

install_readonly files/etc/hosts.template "${ETC}"/hosts
sed -i "s/{HOSTNAME}/${HOST_NAME}/" "${ETC}/hosts"

render "${PIEMAN_DIR}"/files/network/interfaces.j2 "${ETC}"/network/interfaces

if ${ENABLE_WIRELESS}; then
    if is_debian_based; then
        echo brcmfmac > "${ETC}"/modules-load.d/networking.conf

        mkdir -p "${R}"/lib/firmware/brcm

        wget https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/86e88fbf0345da49555d0ec34c80b4fbae7d0cd3/brcm/brcmfmac43430-sdio.bin -O "${R}"/lib/firmware/brcm/brcmfmac43430-sdio.bin
        wget https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/86e88fbf0345da49555d0ec34c80b4fbae7d0cd3/brcm/brcmfmac43430-sdio.txt -O "${R}"/lib/firmware/brcm/brcmfmac43430-sdio.txt

        install_readonly files/network/wpa_supplicant.conf "${ETC}"/wpa_supplicant/wpa_supplicant.conf

        if [[ -n ${WPA_SSID} ]]; then
            do_wpa_passphrase >> "${ETC}"/wpa_supplicant/wpa_supplicant.conf
        fi
    fi
fi

if is_alpine; then
    info "Adding the hostname service to the default runlevel"
    chroot_exec rc-update add hostname default

    info "Adding the networking service to the default runlevel"
    chroot_exec rc-update add networking default

    install_exec files/etc/local.d/11-up_eth0.start "${ETC}"/local.d/11-up_eth0.start

    # The networking service should depend on the local service since one of
    # the scripts from /etc/local.d raises the network interface.
    sed -i '/^\tneed/ s/$/ local/' "${ETC}/init.d/networking"
fi

send_request_to_bsc_server DONE_WITH_NETWORKING_CODE
