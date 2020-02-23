#!/usr/bin/env bash

# MAINTAINER Barcus <barcus@tou.nu>

if [ ! -f /etc/bareos/bareos-config.control ]
  then
  tar xfvz /bareos-fd.tgz

  # Force client/file daemon password
  sed -i "s#Password = .*#Password = \"${BAREOS_FD_PASSWORD}\"#" /etc/bareos/bareos-fd.d/director/bareos-dir.conf

  # Control file
  touch /etc/bareos/bareos-config.control
fi

find /etc/bareos/bareos-fd.d ! -user bareos -exec chown bareos {} \;
exec "$@"
