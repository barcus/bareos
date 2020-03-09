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
find /etc/bareos/bareos-sd.d ! -user bareos -exec chown bareos {} \;
chown -R bareos /var/lib/bareos/storage

# Run Dockerfile CMD
exec "$@"
