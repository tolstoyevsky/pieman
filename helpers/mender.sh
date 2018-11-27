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

# Checks if the Mender dependencies are satisfied.
# Globals:
#     None
# Arguments:
#     None
# Returns:
#     0 or 1 depending on the result.
are_mender_dependencies_satisfied() {
    local ret=0

    >&2 echo -n "checking /usr/include/sys/types.h... "
    yes_or_no "[ -f /usr/include/sys/types.h ]" || ret=1

    >&2 echo -n "checking bc... "
    yes_or_no "[ ! -z $(which bc) ]" || ret=1

    >&2 echo -n "checking cc... "
    yes_or_no "[ ! -z $(which cc) ]" || ret=1

    >&2 echo -n "checking dtc... "
    yes_or_no "[ ! -z $(which dtc) ]" || ret=1

    >&2 echo -n "checking go... "
    yes_or_no "[ ! -z $(which go) ]" || ret=1

    >&2 echo -n "checking make... "
    yes_or_no "[ ! -z $(which make) ]" || ret=1

    return "${ret}"
}

# Installs the Mender client.
# Globals:
#     BOOT
#     MENDER_SERVER_URL
#     MENDER_TENANT_TOKEN
#     MOUNT_POINT
#     PIEMAN_DIR
#     TOOLSET_DIR
# Arguments:
#     None
# Returns:
#     None
install_mender() {
    local etc_mender_dir="${MOUNT_POINT}"/etc/mender
    local mender_identity_dir="usr/share/mender/identity"
    local mender_inventory_dir="usr/share/mender/inventory"

    # The kernel and dtb files are supposed to be placed in /boot
    cp "${BOOT}"/kernel7.img "${MOUNT_POINT}"/boot/zImage
    cp "${BOOT}"/*.dtb "${MOUNT_POINT}"/boot

    #
    # Install Mender client
    #

    # Install the daemon executable and its configuration files
    install -m 0755 "${TOOLSET_DIR}/mender/mender" "${MOUNT_POINT}"/usr/bin/mender
    install -d "${etc_mender_dir}"
    install -m 0644 "${PIEMAN_DIR}"/files/mender/mender.conf.template "${etc_mender_dir}"/mender.conf
    sed -i -e "s#{MENDER_INVENTORY_POLL_INTERVAL}#${MENDER_INVENTORY_POLL_INTERVAL}#" "${etc_mender_dir}"/mender.conf
    sed -i -e "s#{MENDER_RETRY_POLL_INTERVAL}#${MENDER_RETRY_POLL_INTERVAL}#" "${etc_mender_dir}"/mender.conf
    sed -i -e "s#{MENDER_SERVER_URL}#${MENDER_SERVER_URL}#" "${etc_mender_dir}"/mender.conf
    sed -i -e "s#{MENDER_TENANT_TOKEN}#${MENDER_TENANT_TOKEN}#" "${etc_mender_dir}"/mender.conf
    sed -i -e "s#{MENDER_UPDATE_POLL_INTERVAL}#${MENDER_UPDATE_POLL_INTERVAL}#" "${etc_mender_dir}"/mender.conf
    install -m 0644 "${PIEMAN_DIR}"/files/mender/artifact_info "${etc_mender_dir}"
    sed -i -e "s#{MENDER_ARTIFACT_NAME}#${MENDER_ARTIFACT_NAME}#" "${etc_mender_dir}"/artifact_info

    # Make the daemon start on boot
    install -m 0644 "${PIEMAN_DIR}"/files/mender/mender.service "${MOUNT_POINT}"/lib/systemd/system
    ln -s "${MOUNT_POINT}"/lib/systemd/system/mender.service "${MOUNT_POINT}"/etc/systemd/system/multi-user.target.wants/mender.service

    # Install fw_printenv and fw_setenv
    install -m 0755 "${TOOLSET_DIR}"/mender/fw_printenv "${MOUNT_POINT}"/sbin/fw_printenv
    ln -fs /sbin/fw_printenv "${MOUNT_POINT}"/usr/bin/fw_printenv
    ln -fs /sbin/fw_printenv "${MOUNT_POINT}"/sbin/fw_setenv
    ln -sf /data/u-boot/fw_env.config "${MOUNT_POINT}"/etc/fw_env.config

    # Mender generates keys (mender-agent.pem) and places them in
    # /var/lib/mender. The keys must be physically located on the data
    # partition because the keys must present on both A and B partitions.
    ln -sf /data/mender "${MOUNT_POINT}/var/lib/mender"

    install -m 0644 "${PIEMAN_DIR}"/files/mender/fstab "${MOUNT_POINT}"/etc/fstab

    install -d "${MOUNT_POINT}/${mender_identity_dir}"
    install -d "${MOUNT_POINT}/${mender_inventory_dir}"

    install -t "${MOUNT_POINT}/${mender_identity_dir}" -m 0755 "${TOOLSET_DIR}"/mender/mender-device-identity
    install -t "${MOUNT_POINT}/${mender_inventory_dir}" -m 0755 "${TOOLSET_DIR}"/mender/mender-inventory-*
}
