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

check_if_variable_is_set ETC

info "Preparing ${ETC}/rc.firstboot"

touch ${ETC}/rc.firstboot
chmod +x ${ETC}/rc.firstboot

for script in files/firstboot/*.sh; do
    cat ${script} >> ${ETC}/rc.firstboot
done

# /etc/rc.firstboot has to destroy itself and its traces after first run.
cat <<EOT >> ${ETC}/rc.firstboot
rm -f /etc/rc.firstboot
sed -i '/.*rc.firstboot/d' /etc/rc.local
EOT

if [ ! -f ${ETC}/rc.local ]; then
    install_exec files/etc/rc.local ${ETC}/rc.local
fi

sed -i "/exit 0/d" ${ETC}/rc.local
echo "/etc/rc.firstboot" >> ${ETC}/rc.local
echo "exit 0" >> ${ETC}/rc.local
