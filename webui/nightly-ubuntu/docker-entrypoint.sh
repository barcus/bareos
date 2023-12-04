#!/usr/bin/env bash

if [ ! -f /etc/bareos-webui/bareos-config.control ];then
  tar xzf /bareos-webui.tgz --backup=simple --suffix=.before-control

  # Update bareos-webui config
  sed -i 's#diraddress.*#diraddress = '\""${BAREOS_DIR_HOST}"\"'#' \
    /etc/bareos-webui/directors.ini

  # Control file
  touch /etc/bareos-webui/bareos-config.control
fi

apache_conf="/etc/apache2/sites-available/000-default.conf"

# Set document root
sed -i "s#/var/www/html#/usr/share/bareos-webui/public#g" $apache_conf

# Enable Apache server stats
if [ "${SERVER_STATS}" == "yes" ]; then
  sed -i 's!#ServerName.*!Alias /server-status /var/www/dummy!' $apache_conf
fi

# Run Dockerfile CMD
exec "$@"
