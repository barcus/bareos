#!/usr/bin/env ash

if [ ! -f /etc/bareos-webui/bareos-config.control ]
  then
  tar xfvz /bareos-webui-config.tgz

  # Update bareos-webui config
  sed -i "s/diraddress = \"localhost\"/diraddress = \"${BAREOS_DIR_HOST}\"/" /etc/bareos-webui/directors.ini

  # Control file
  touch /etc/bareos-webui/bareos-config.control
fi

if [ ! -f /usr/share/bareos-webui/bareos-config.control ]
  then
  tar xfvz /bareos-webui-code.tgz
  touch /usr/share/bareos-webui/bareos-config.control
fi

# set php-fpm host andd port
sed -i "s/fastcgi_pass 127.0.0.1:9000;/fastcgi_pass ${PHP_FPM_HOST}:${PHP_FPM_PORT};/" /etc/nginx/conf.d/bareos-webui.conf

exec "$@"
