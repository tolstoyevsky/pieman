# Copyright (C) 2017 Denis Mosolov <denismosolov@cusdeb.com>
# Copyright (C) 2018 Evgeny Golyshev <eugulixes@gmail.com>
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

if ! check_if_variable_is_set TIME_ZONE; then
    >&2 echo "TIME_ZONE is not specified"
    exit 1
fi

info "setting up locale"

if is_debian_based; then
    if [ -z "$(grep "${LOCALE}" ${ETC}/locale.gen)" ]; then
        fatal "could not find locale ${LOCALE}"
        do_exit
    fi
fi

case ${PIECES[0]} in
raspbian|devuan)
    sed -i "s/^# *\($LOCALE\)/\1/" ${ETC}/locale.gen

    chroot_exec locale-gen
    ;;
ubuntu)
    if [[ ${PIECES[1]} == "artful" ]]; then
        info "skipping setting up locale for Ubuntu Artful since it's not" \
             "possible so far using emulator"
    else
        chroot_exec locale-gen "${LOCALE}"
    fi
    ;;
esac

info "setting up timezone"
# Set timezone
# https://bugs.launchpad.net/ubuntu/+source/tzdata/+bug/1554806
chroot_exec ln -fs /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime


if is_alpine; then
    echo "${TIME_ZONE}" > ${ETC}/timezone
elif is_debian_based; then
    chroot_exec dpkg-reconfigure -f noninteractive tzdata
fi
