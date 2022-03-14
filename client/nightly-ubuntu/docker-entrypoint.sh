#!/usr/bin/env bash
#set -x

bareos_fd_config="/etc/bareos/bareos-fd.d/director/bareos-dir.conf"

if [ "${FORCE_ROOT}" = true ]; then
  BAREOS_DAEMON_USER='root'
  BAREOS_DAEMON_GROUP='root'
fi

if [ $(id -u) = '0' ]; then
  [ -n "${PUID}" ] && usermod -u ${PUID} ${BAREOS_DAEMON_USER}
  [ -n "${PGID}" ] && groupmod -g ${PGID} ${BAREOS_DAEMON_GROUP}

  if [ ! -f /etc/bareos/bareos-config.control ]; then
    tar xzf /bareos-fd.tgz --backup=simple --suffix=.before-control

    # Force client/file daemon password
    sed -i 's#Password = .*#Password = '\""${BAREOS_FD_PASSWORD}"\"'#' $bareos_fd_config

    # Control file
    touch /etc/bareos/bareos-config.control
  fi

  # Fix permissions
  find /etc/bareos ! -user ${BAREOS_DAEMON_USER} -exec chown ${BAREOS_DAEMON_USER}:${BAREOS_DAEMON_GROUP} {} \;
  chown -R ${BAREOS_DAEMON_USER}:${BAREOS_DAEMON_GROUP} /var/lib/bareos /var/log/bareos

  # Gosu
  [ "${BAREOS_DAEMON_USER}" != 'root' ] && exec gosu "${BAREOS_DAEMON_USER}" "$BASH_SOURCE" "$@"
fi

exec "$@"
