#!/usr/bin/env bash

bareos_sd_config="/etc/bareos/bareos-sd.d/director/bareos-dir.conf"

if [ ! -f /etc/bareos/bareos-config.control ]; then
  tar xfz /bareos-sd.tgz --backup=simple --suffix=.before-control

  # Update bareos-storage configs
  sed -i 's#Password = .*#Password = '\""${BAREOS_SD_PASSWORD}"\"'#' $bareos_sd_config

  # Control file
  touch /etc/bareos/bareos-config.control
fi

# Fix permissions
find /var/lib/bareos ! -user bareos -exec chown bareos {} \;
find /etc/bareos/bareos-sd.d ! -user bareos -exec chown bareos {} \;
find /dev -regex "/dev/[n]?st[0-9]+" ! -user bareos -exec chown bareos {} \;
find /dev -regex "/dev/tape/.*" ! -user bareos -exec chown bareos {} \;

# Run Dockerfile CMD
exec "$@"
