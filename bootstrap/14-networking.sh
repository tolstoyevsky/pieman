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

dns_is_set=false

if [ ! -z ${ENABLE_GOOGLE_DNS} ]; then
    echo "nameserver 8.8.8.8"  > ${ETC}/resolvconf/resolv.conf.d/base
    echo "nameserver 8.8.4.4" >> ${ETC}/resolvconf/resolv.conf.d/base
    dns_is_set=true
fi

if [ ! -z ${ENABLE_BASIC_YANDEX_DNS} ]; then
    echo "nameserver 77.88.8.8"  > ${ETC}/resolvconf/resolv.conf.d/base
    echo "nameserver 77.88.8.1" >> ${ETC}/resolvconf/resolv.conf.d/base
    dns_is_set=true

fi

if [ ! -z ${ENABLE_FAMILY_YANDEX_DNS} ]; then
    echo "nameserver 77.88.8.7"  > ${ETC}/resolvconf/resolv.conf.d/base
    echo "nameserver 77.88.8.3" >> ${ETC}/resolvconf/resolv.conf.d/base
    dns_is_set=true

fi

if [ ! -z ${ENABLE_CUSTOM_DNS} ]; then
    echo ${ENABLE_CUSTOM_DNS} > ${ETC}/resolvconf/resolv.conf.d/base
    dns_is_set=true
fi

if ${dns_is_set}; then
    chroot_exec resolvconf -u
fi
