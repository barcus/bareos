#!/usr/bin/env bash

if [ ! -f /etc/bareos-webui/bareos-config.control ]
  then
  tar xfvz /bareos-webui.tgz

  # Update bareos-webui config
  sed -i "s/diraddress = \"localhost\"/diraddress = \"${BAREOS_DIR_HOST}\"/" /etc/bareos-webui/directors.ini

  # Control file
  touch /etc/bareos-webui/bareos-config.control
fi

#set document root for withouth subdir
sed -i "s/\/var\/www\/html/\/usr\/share\/bareos-webui\/public/g" /etc/apache2/sites-available/000-default.conf

exec "$@"
