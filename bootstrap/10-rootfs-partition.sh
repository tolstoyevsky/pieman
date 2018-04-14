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

check_if_variable_is_set R

# Expand the base system.

add_package_to_base_packages locales

base_packages="$(get_attr_or_nothing ${OS} base)"
if [ ! -z "${base_packages}" ]; then
    for package in ${base_packages}; do
        add_package_to_base_packages "${package}"
    done
fi

if [ ! -z ${BASE_DIR} ] && [ -d ${BASE_DIR} ]; then
    info "using ${BASE_DIR} instead of creating chroot environment via debootstrap."
    cp -r --preserve ${BASE_DIR} ${R}
else
    info "BASE_DIR is not specified or does not exist. Running debootstrap to create chroot environment."

    create_keyring

    run_scripts ${SOURCE_DIR}/pre-first-stage

    run_first_stage

    run_scripts ${SOURCE_DIR}/post-first-stage

    run_scripts ${SOURCE_DIR}/pre-second-stage

    run_second_stage

    run_scripts ${SOURCE_DIR}/post-second-stage

    # To prevent NO_PUBKEY when the packages will be installed a bit later.
    mark_keys_as_trusted
fi

info "mounting proc and sys filesystems to chroot environment"
mount_required_filesystems
