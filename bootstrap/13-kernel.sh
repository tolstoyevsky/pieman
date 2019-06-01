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

for var in OS SOURCE_DIR; do
    check_if_variable_is_set ${var}
done

build_script="$(get_attr_or_nothing ${OS} kernel build_script)"
kernel_package="$(get_attr_or_nothing ${OS} kernel package)"

run_scripts ${SOURCE_DIR}/pre-kernel-installation

if [[ ! -z "${build_script}" ]]; then
    info "building and installing kernel from source code"

    cp "${SOURCE_DIR}/${build_script}" "${R}"

    chroot_exec sh "${build_script}"

    rm "${R}/${build_script}"
elif [[ ! -z ${kernel_package} ]]; then
    info "installing kernel package"

    install_packages ${kernel_package}
else
    info "skipping kernel installation because neither build_script nor package was specified in pieman.yml"
fi

run_scripts ${SOURCE_DIR}/post-kernel-installation

send_request_to_bsc_server INSTALLED_KERNEL_CODE
