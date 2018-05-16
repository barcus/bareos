#!/usr/bin/env bash

# MAINTAINER Barcus <barcus@tou.nu>

if [ ! -f /etc/bareos/bareos-config.control ]
  then
  tar xfvz /bareos-dir.tgz

  # Download default admin profile config
  if [ ! -f /etc/bareos/bareos-dir.d/profile/webui-admin.conf ]
    then
    curl --silent --insecure https://raw.githubusercontent.com/bareos/bareos/master/webui//install/bareos/bareos-dir.d/profile/webui-admin.conf --output /etc/bareos/bareos-dir.d/profile/webui-admin.conf
  fi

  # Download default webUI config
  if [ ! -f /etc/bareos/bareos-dir.d/console/admin.conf ]
    then
    curl --silent --insecure https://raw.githubusercontent.com/bareos/bareos/master/webui//install/bareos/bareos-dir.d/console/admin.conf.example --output /etc/bareos/bareos-dir.d/console/admin.conf
  fi

  # Update bareos-director configs
  # Director / mycatalog & mail report
  sed -i "s#dbuser = bareos#dbuser = bareos\n  dbpassword = ${DB_PASSWORD}#" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i "s#dbname = bareos#dbname = bareos\n  dbaddress = \"${DB_HOST}\"\n  dbport = \"${DB_PORT}\"#" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i "s#/usr/bin/bsmtp -h localhost#/usr/bin/bsmtp -h ${SMTP_HOST}#" /etc/bareos/bareos-dir.d/messages/Daemon.conf
  sed -i "s#mail = root@localhost#mail = ${ADMIN_MAIL}#" /etc/bareos/bareos-dir.d/messages/Daemon.conf
  sed -i "s#/usr/bin/bsmtp -h localhost#/usr/bin/bsmtp -h ${SMTP_HOST}#" /etc/bareos/bareos-dir.d/messages/Standard.conf
  sed -i "s#mail = root@localhost#mail = ${ADMIN_MAIL}#" /etc/bareos/bareos-dir.d/messages/Standard.conf
  # storage daemon
  sed -i "s#Address = .*#Address = \"${BAREOS_SD_HOST}\"#" /etc/bareos/bareos-dir.d/storage/File.conf
  sed -i "s#Password = .*#Password = \"${BAREOS_SD_PASSWORD}\"#" /etc/bareos/bareos-dir.d/storage/File.conf
  # client/file daemon
  sed -i "s#Address = .*#Address = \"${BAREOS_FD_HOST}\"#" /etc/bareos/bareos-dir.d/client/bareos-fd.conf
  sed -i "s#Password = .*#Password = \"${BAREOS_FD_PASSWORD}\"#" /etc/bareos/bareos-dir.d/client/bareos-fd.conf
  # webUI
  sed -i "s#Password = .*#Password = \"${BAREOS_WEBUI_PASSWORD}\"#" /etc/bareos/bareos-dir.d/console/admin.conf

  # Control file
  touch /etc/bareos/bareos-config.control
fi

if [ ! -f /etc/bareos/bareos-db.control ]
  then
    sleep 15
    # Iinit Postgres DB
    export PGUSER=postgres
    export PGHOST=${DB_HOST}
    export PGPASSWORD=${DB_PASSWORD}
    psql -c 'create user bareos with createdb createrole createuser login;'
    psql -c "alter user bareos password '${DB_PASSWORD}';"
    /usr/lib/bareos/scripts/create_bareos_database
    /usr/lib/bareos/scripts/make_bareos_tables
    /usr/lib/bareos/scripts/grant_bareos_privileges

    # Control file
    touch /etc/bareos/bareos-db.control
  else
    # Try Postgres upgrade
    export PGUSER=postgres
    export PGHOST=${DB_HOST}
    export PGPASSWORD=${DB_PASSWORD}
    /usr/lib/bareos/scripts/update_bareos_tables
    /usr/lib/bareos/scripts/grant_bareos_privileges
fi

find /etc/bareos/bareos-dir.d ! -user bareos -exec chown bareos {} \;
exec "$@"
