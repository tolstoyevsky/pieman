# Copyright (C) 2019 Evgeny Golyshev <eugulixes@gmail.com>
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

# Checks if it's possible to connect to the Redis server, specified via the
# Pieman parameters.
# Globals:
#     ENABLE_BSC_CHANNEL
#     PIEMAN_UTILS_DIR
#     PYTHON
#     REDIS_HOST
#     REDIS_IS_AVAILABLE
#     REDIS_PORT
# Arguments:
#     None
# Returns:
#     None
check_redis() {
    if ${ENABLE_BSC_CHANNEL}; then
        info "checking if it is possible to connect to the Redis server" \
             "${REDIS_HOST}:${REDIS_PORT}"

        if ! ${PYTHON} "${PIEMAN_UTILS_DIR}"/check_redis.py -H "${REDIS_HOST}" -P "${REDIS_PORT}"; then
            fatal "could not connect to Redis"

            REDIS_IS_AVAILABLE=false

            # Don't exit with non-zero code since the problem related to Redis
            # mustn't affect the success of the current build.
        else
            info "Redis is available"
        fi
    fi
}

# Sends a request to Build Status Codes server.
# Globals:
#     ENABLE_BSC_CHANNEL
#     PIEMAN_UTILS_DIR
#     PROJECT_NAME
#     PYTHON
#     REDIS_IS_AVAILABLE
# Arguments:
#     None
# Returns:
#     None
send_request_to_bsc_server() {
    if ${REDIS_IS_AVAILABLE} && ${ENABLE_BSC_CHANNEL}; then
        local request=$1
        local unix_socket_path="/var/run/bscd-${PROJECT_NAME}.sock"

        ${PYTHON} "${PIEMAN_UTILS_DIR}"/bsc.py \
            --unix-socket-name "${unix_socket_path}" \
            "${!request}" > /dev/null 2>&1
    fi
}

# Starts the Build Status Codes server.
# Globals:
#     ENABLE_BSC_CHANNEL
#     PIEMAN_UTILS_DIR
#     PROJECT_NAME
#     PYTHON
#     REDIS_HOST
#     REDIS_IS_AVAILABLE
#     REDIS_PORT
# Arguments:
#     None
# Returns:
#     None
start_bscd() {
    if ${REDIS_IS_AVAILABLE} && ${ENABLE_BSC_CHANNEL}; then
        local daemon_started=false
        local pid_file="/var/run/bscd-${PROJECT_NAME}.pid"
        local log_file="${PIEMAN_DIR}/build/bscd-${PROJECT_NAME}.log"
        local unix_socket_path="/var/run/bscd-${PROJECT_NAME}.sock"

        info "starting the Build Status Codes server"
        ${PYTHON} "${PIEMAN_UTILS_DIR}"/bscd.py \
            --channel-name "bscd-${PROJECT_NAME}" \
            --daemonize \
            --log-file-prefix "${log_file}" \
            --pid "${pid_file}" \
            --redis-host "${REDIS_HOST}" \
            --redis-port "${REDIS_PORT}" \
            --unix-socket-name "${unix_socket_path}"

        local max_retries=10
        for i in $(eval echo "{1..${max_retries}}"); do
            if [[ ! -f "${pid_file}" ]]; then
                info "waiting when bscd is up"
                sleep 1
            else
                daemon_started=true
                break
            fi
        done

        if ${daemon_started}; then
            info "bscd -- channel name is bscd-${PROJECT_NAME}"
            info "bscd -- log file is ${log_file}"
            info "bscd -- pid file is ${pid_file}"
            info "bscd -- Unix socket path is ${unix_socket_path}"
        else
            fatal "could not start bscd"

            # Don't exit with non-zero code since the problem related to bscd
            # mustn't affect the success of the current build.
        fi
    fi
}

# Stops the Build Status Codes server.
# Globals:
#     PROJECT_NAME
# Arguments:
#     None
# Returns:
#     None
stop_bscd() {
    local pid_file="/var/run/bscd-${PROJECT_NAME}.pid"

    if [[ -f "${pid_file}" ]]; then
        local daemon_stopped=false
        local max_retries=10

        info "shutting down bscd"
        send_request_to_bsc_server EXIT_REQUEST

        for i in $(eval echo "{1..${max_retries}}"); do
            if [[ -f "${pid_file}" ]]; then
                info "waiting when bscd is down ($((max_retries - i)) attempts left)"
                sleep 1
            else
                daemon_stopped=true
                break
            fi
        done

        if ! ${daemon_stopped}; then
            fatal "could not stop bscd"
        fi
    fi
}
