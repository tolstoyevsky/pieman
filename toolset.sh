# Copyright (C) 2018-2020 Evgeny Golyshev <eugulixes@gmail.com>
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

build_toolset

# Correct ownership if needed
#pieman_dir_ownership="$(get_ownership "${PIEMAN_DIR}")"
#if [ "$(get_ownership "${TOOLSET_FULL_PATH}")" != "${pieman_dir_ownership}" ]; then
#    info "correcting ownership for ${TOOLSET_FULL_PATH}"
#    chown -R "${pieman_dir_ownership}" "${TOOLSET_FULL_PATH}"
#fi
#
#if ${PREPARE_ONLY_TOOLSET}; then
#    success "exiting since PREPARE_ONLY_TOOLSET is set to true"
#
#    exit 0
#fi
