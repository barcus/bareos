#!/usr/bin/env ash

github_bareos='raw.githubusercontent.com/bareos/bareos'
webui_admin_conf='master/webui/install/bareos/bareos-dir.d/profile/webui-admin.conf'
admin_conf='master/webui/install/bareos/bareos-dir.d/console/admin.conf.example'

if [ ! -f /etc/bareos/bareos-config.control ]; then
  tar xzf /bareos-dir.tgz --backup=simple --suffix=.before-control

  # Download default admin profile config
  if [ ! -f /etc/bareos/bareos-dir.d/profile/webui-admin.conf ]; then
    curl --silent --insecure "https://${github_bareos}/${webui_admin_conf}" \
      --output /etc/bareos/bareos-dir.d/profile/webui-admin.conf
  fi

  # Download default webUI admin config
  if [ ! -f /etc/bareos/bareos-dir.d/console/admin.conf ]; then
    curl --silent --insecure "https://${github_bareos}/${admin_conf}" \
      --output /etc/bareos/bareos-dir.d/console/admin.conf
  fi

  # Update bareos-director configs
  # Director / mycatalog & mail report
  sed -i 's#dbuser =.*#dbuser = root#' \
    /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i 's#dbpassword =.*#dbpassword = '\""${DB_PASSWORD}"\"'#' \
    /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i 's#dbname =.*#dbname = bareos\n  dbaddress = '\""${DB_HOST}"\"'\n  dbport = '\""${DB_PORT}"\"'#' \
    /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i 's#dbdriver = .*#dbdriver = '\""mysql"\"'#' \
    /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i "s#/usr/bin/bsmtp -h localhost#/usr/bin/bsmtp -h ${SMTP_HOST}#" \
    /etc/bareos/bareos-dir.d/messages/Daemon.conf
  sed -i "s#mail = root@localhost#mail = ${ADMIN_MAIL}#" \
    /etc/bareos/bareos-dir.d/messages/Daemon.conf
  sed -i "s#/usr/bin/bsmtp -h localhost#/usr/bin/bsmtp -h ${SMTP_HOST}#" \
    /etc/bareos/bareos-dir.d/messages/Standard.conf
  sed -i "s#mail = root@localhost#mail = ${ADMIN_MAIL}#" \
    /etc/bareos/bareos-dir.d/messages/Standard.conf

  # Setup webhook
  if [ "${WEBHOOK_NOTIFICATION}" = true ]; then
    sed -i "s#/usr/bin/bsmtp -h.*#/usr/local/bin/webhook-notify %t %e %c %l %n\"#" \
      /etc/bareos/bareos-dir.d/messages/Daemon.conf
    sed -i "s#/usr/bin/bsmtp -h.*#/usr/local/bin/webhook-notify %t %e %c %l %n\"#" \
      /etc/bareos/bareos-dir.d/messages/Standard.conf
  fi

  # storage daemon
  sed -i 's#Address = .*#Address = '\""${BAREOS_SD_HOST}"\"'#' \
    /etc/bareos/bareos-dir.d/storage/File.conf
  sed -i 's#Password = .*#Password = '\""${BAREOS_SD_PASSWORD}"\"'#' \
    /etc/bareos/bareos-dir.d/storage/File.conf

  # client/file daemon
  sed -i 's#Address = .*#Address = '\""${BAREOS_FD_HOST}"\"'#' \
    /etc/bareos/bareos-dir.d/client/bareos-fd.conf
  sed -i 's#Password = .*#Password = '\""${BAREOS_FD_PASSWORD}"\"'#' \
    /etc/bareos/bareos-dir.d/client/bareos-fd.conf

  # webUI
  sed -i 's#Password = .*#Password = '\""${BAREOS_WEBUI_PASSWORD}"\"'#' \
    /etc/bareos/bareos-dir.d/console/admin.conf

  # MyCatalog Backup
  sed -i "s#/var/lib/bareos/bareos.sql#/var/lib/bareos-director/bareos.sql#" \
    /etc/bareos/bareos-dir.d/fileset/Catalog.conf
  sed -i "s#make_catalog_backup#make_catalog_backup.pl#" \
    /etc/bareos/bareos-dir.d/job/BackupCatalog.conf

  # Control file
  touch /etc/bareos/bareos-config.control
fi

if [[ -z ${CI_TEST} ]] ; then
  # MySQL check
  # Waiting for mysqld
  sqlup=1
  while [ "$sqlup" -ne 0 ] ; do
    echo "Waiting for mysqld..."
    mysqladmin --silent -u root -p"${DB_PASSWORD}" -h "${DB_HOST}" ping
    if [ $? -ne 0 ] ; then
      sqlup=1
      sleep 5
    else
      sqlup=0
      echo "...mysqld is alive"
    fi
  done
fi

# Set mysqld access for root
echo -e "[client]\nhost=${DB_HOST}\nuser=root\npassword=${DB_PASSWORD}" > /root/.my.cnf

# MySQL init for Bareos if required
if [ ! -f /etc/bareos/bareos-db.control ] ; then
  # Init MySQL DB
  /etc/bareos/scripts/create_bareos_database
  /etc/bareos/scripts/make_bareos_tables

  # Control file
  touch /etc/bareos/bareos-db.control
else
  # Try MySQL DB upgrade
  /etc/bareos/scripts/update_bareos_tables
fi

# Fix permissions
find /etc/bareos/bareos-dir.d ! -user bareos -exec chown bareos {} \;
chown bareos:bareos /var/lib/bareos /var/log/bareos

# Run Dockerfile CMD
exec "$@"
