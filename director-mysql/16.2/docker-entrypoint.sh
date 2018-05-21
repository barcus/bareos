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
  sed -i "s#dbuser =.*#dbuser = root#" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i "s#dbpassword =.*#dbpassword = \"${DB_PASSWORD}\"#" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i "s#dbname =.*#dbname = bareos\n  dbaddress = \"${DB_HOST}\"\n  dbport = \"${DB_PORT}\"#" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
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
  # MyCatalog Backup
  sed -i "s#/var/lib/bareos/bareos.sql#/var/lib/bareos-director/bareos.sql#" /etc/bareos/bareos-dir.d/fileset/Catalog.conf

  # Control file
  touch /etc/bareos/bareos-config.control
fi

if [ ! -f /etc/bareos/bareos-db.control ]
  then
    # MySQL init
    # Waiting for MySQL
    sqlup=1
    msg="Waiting for MySQL..."
    while [ "$sqlup" -ne 0 ] ; do mysqladmin -u root -p"${DB_PASSWORD}" -h "${DB_HOST}" ping ; sqlup=$? ; echo "$msg" && sleep 5 ; done

    # Init MySQL DB
    echo -e "[client]\nhost=${DB_HOST}\nuser=root\npassword=${DB_PASSWORD}" > /root/.my.cnf
    /usr/lib/bareos/scripts/create_bareos_database
    /usr/lib/bareos/scripts/make_bareos_tables
    # Only for Postgres
    #/usr/lib/bareos/scripts/grant_bareos_privileges

    # Control file
    touch /etc/bareos/bareos-db.control
  else
    # Try MySQL upgrade
    # Waiting for MySQL
    sqlup=1
    msg="Waiting for MySQL..."
    while [ "$sqlup" -ne 0 ] ; do mysqladmin -u root -p"${DB_PASSWORD}" -h "${DB_HOST}" ping ; sqlup=$? ; echo "$msg" && sleep 5 ; done

    echo -e "[client]\nhost=${DB_HOST}\nuser=root\npassword=${DB_PASSWORD}" > /root/.my.cnf
    /usr/lib/bareos/scripts/update_bareos_tables
fi

find /etc/bareos/bareos-dir.d ! -user bareos -exec chown bareos {} \;
chown bareos:bareos /var/lib/bareos
exec "$@"
