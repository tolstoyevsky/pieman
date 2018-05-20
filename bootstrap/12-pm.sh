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

for var in CREATE_ONLY_CHROOT ENABLE_NONFREE ENABLE_UNIVERSE ETC PIECES; do
    check_if_variable_is_set ${var}
done

if ${ALLOW_UNAUTHENTICATED}; then
    add_option_to_pm_options --allow-unauthenticated
fi

if ${ENABLE_SUDO}; then
    add_package_to_includes sudo
fi

# /etc/rc.firstboot dependencies
add_package_to_includes parted
add_package_to_includes ifupdown

# Networking
add_package_to_includes netbase
add_package_to_includes net-tools
if [[ ${PIECES[0]} -eq "raspbian" ]]; then
    add_package_to_includes dhcpcd5
    if ${ENABLE_WIRELESS}; then
        add_package_to_includes wpasupplicant
        # install only if raspberry pi
        add_package_to_includes firmware-brcm80211
    fi
else
    add_package_to_includes isc-dhcp-client
fi
add_package_to_includes inetutils-ping

# If /etc/apt/sources.list exists, remove the content.
echo "" > ${ETC}/apt/sources.list

# By default /etc/apt/sources.list uses only the main section of the archive.
# However, the ENABLE_NONFREE and ENABLE_UNIVERSE environment variables can
# change the situation.
if [[ ${PIECES[0]} -eq "debian" ]] || [[ ${PIECES[0]} -eq "raspbian" ]]; then
    if ${ENABLE_NONFREE}; then
        additional_sections=" contrib non-free"
    fi
fi

if [[ ${PIECES[0]} -eq "ubuntu" ]]; then
    if ${ENABLE_UNIVERSE}; then
        additional_sections=" universe"
    fi
fi

# Form the content of /etc/apt/sources.list.
for source in `get_attr ${OS} repos`; do
    codename=${PIECES[1]}
    echo "deb ${source} ${codename} main${additional_sections}" >> ${ETC}/apt/sources.list
done

run_scripts ${SOURCE_DIR}/pre-update-indexes

info "updating indexes"
update_indexes

run_scripts ${SOURCE_DIR}/post-update-indexes

dns_params=(
    ENABLE_GOOGLE_DNS
    ENABLE_BASIC_YANDEX_DNS
    ENABLE_FAMILY_YANDEX_DNS
    ENABLE_CUSTOM_DNS
)
for param in ${dns_params[@]}; do
    if [ ! -z "${!param}" ]; then
        add_package_to_includes resolvconf
    fi
done

# Install the packages recommended by the maintainer of the image, specified by
# the user and required by some parameters.

includes="`get_attr_or_nothing ${OS} includes`"
if [ ! -z "${includes}" ]; then
    for i in ${includes}; do
        add_package_to_includes ${i}
    done
fi

if [ ! -z ${INCLUDES} ]; then
    packages_list=`echo ${INCLUDES} | sed -r 's/,/ /g'`

    run_scripts ${SOURCE_DIR}/pre-install

    info "installing ${packages_list}"
    install_packages ${packages_list}

    run_scripts ${SOURCE_DIR}/post-install
fi

run_scripts ${SOURCE_DIR}/pre-upgrade

info "upgrading chroot environment"
upgrade

run_scripts ${SOURCE_DIR}/post-upgrade

if ${CREATE_ONLY_CHROOT}; then
    clean

    info "exiting since CREATE_ONLY_CHROOT is set to true"

    cleanup

    success "Chroot environment ${R} is done. Now you can speed up next builds by passing it to Pieman via the BASE_DIR parameter."

    exit 0
fi
