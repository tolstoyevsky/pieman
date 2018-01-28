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

check_if_variable_is_set ENABLE_USER PASSWORD USER_NAME USER_PASSWORD

if ${ENABLE_USER}; then
    info "creating regular user ${USER_NAME}"
    chroot_exec useradd -m ${USER_NAME} -s /bin/bash

    encrypted_password=`mkpasswd -m sha-512 "${USER_PASSWORD}"`

    chroot_exec usermod -p "${encrypted_password}" ${USER_NAME}
fi

encrypted_password=`mkpasswd -m sha-512 "${PASSWORD}"`

info "setting root password"
chroot_exec usermod -p "${encrypted_password}" root
