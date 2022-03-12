#!/usr/bin/env bash
#set -x

bareos_fd_config="/etc/bareos/bareos-fd.d/director/bareos-dir.conf"

[ -n "${PUID}" ] && usermod -u ${PUID} ${BAREOS_DAEMON_USER}
[ -n "${PGID}" ] && groupmod -g ${PGID} ${BAREOS_DAEMON_GROUP}

if [ $(id -u) = '0' ]; then
  if [ ! -f /etc/bareos/bareos-config.control ]; then
    tar xzf /bareos-fd.tgz --backup=simple --suffix=.before-control

    # Force client/file daemon password
    sed -i 's#Password = .*#Password = '\""${BAREOS_FD_PASSWORD}"\"'#' $bareos_fd_config

    # Control file
    touch /etc/bareos/bareos-config.control
  fi

  # Fix permissions
  find /etc/bareos ! -user ${BAREOS_DAEMON_USER} -exec chown ${BAREOS_DAEMON_USER}:${BAREOS_DAEMON_GROUP} {} \;

  # Gosu
  exec gosu "${BAREOS_DAEMON_USER}" "$BASH_SOURCE" "$@"
fi

exec "$@"
