# Copyright (C) 2017-2021 Evgeny Golyshev <eugulixes@gmail.com>
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

# Expand the base system.

if is_debian_based; then
    add_package_to_base_packages locales
fi

base_packages="$(get_attr_or_nothing base)"
if [[ -n ${base_packages} ]]; then
    for package in ${base_packages}; do
        add_package_to_base_packages "${package}"
    done
fi

if [[ -n ${BASE_DIR} ]] && [[ -n ${BASE_DIR} ]]; then
    info "using ${BASE_DIR} instead of creating chroot environment."
    cp -r --preserve "${BASE_DIR}" "${R}"
else
    info "BASE_DIR is not specified or does not exist. Creating chroot environment."

    create_chroot_environment
fi

send_request_to_bsc_server PREPARED_CHROOT_ENV_CODE

info "mounting proc and sys filesystems to chroot environment"
mount_required_filesystems
