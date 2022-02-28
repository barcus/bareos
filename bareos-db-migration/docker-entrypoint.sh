#!/usr/bin/env bash
#set -x

if [[ -z ${CI_TEST} ]] ; then
  # Waiting for Postgresql is up
  sqlup=1
  while [ "$sqlup" -ne 0 ] ; do
    echo "Waiting for postgresql..."
    pg_isready --host="${PGSQL_DB_HOST}" --port="${PGSQL_DB_PORT}"
    if [ $? -ne 0 ] ; then
      sqlup=1
      sleep 5
    else
      sqlup=0
      echo "[!]...postgresql is alive"
    fi
  done
fi

if [[ -z ${CI_TEST} ]] ; then
  # Waiting for Mysql is up
  sqlup=1
  while [ "$sqlup" -ne 0 ] ; do
    echo "Waiting for mysqld..."
    mysqladmin --silent -u ${MYSQL_DB_USER} -p"${MYSQL_DB_PASSWORD}" -h "${MYSQL_DB_HOST}" ping
    if [ $? -ne 0 ] ; then
      sqlup=1
      sleep 5
    else
      sqlup=0
      echo "[!]...mysqld is alive"
    fi
  done
fi

# Prepare Catalog configs to init new DB if required
cat << \EOF > /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
Catalog {
  Name = MyCatalog-new
  dbdriver = "postgresql"
  dbname = "$PGSQL_DB_NAME"
  dbaddress = "$PGSQL_DB_HOST"
  dbport = "$PGSQL_DB_PORT"
  dbuser = "$PGSQL_DB_USER"
  dbpassword = "$PGSQL_DB_PASSWORD"
}
EOF

export PGUSER=${PGSQL_ADMIN_USER}
export PGHOST=${PGSQL_DB_HOST}
export PGPASSWORD=${PGSQL_ADMIN_PASSWORD}

# Init Postgresql DB
echo "Bareos PG DB init"
echo "Bareos PG DB init: Create user"
psql -c "create user ${PGSQL_DB_USER} with createdb createrole createuser login;"
echo "Bareos PG DB init: Set user password"
psql -c "alter user ${PGSQL_DB_USER} password '${PGSQL_DB_PASSWORD}';"

echo "Bareos PG DB init: Create Bareos database"
/usr/lib/bareos/scripts/create_bareos_database 2>/dev/null
echo "Bareos PG DB init: Create Bareos tables"
/usr/lib/bareos/scripts/make_bareos_tables 2>/dev/null
echo "Bareos PG DB init: Grant Bareos privileges"
/usr/lib/bareos/scripts/grant_bareos_privileges 2>/dev/null

# Prepare Catalog configs for migration
cat << EOF > /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
Catalog {
  Name = MyCatalog
  DB Driver = "mysql"
  DB Name = "$MYSQL_DB_NAME"
  DB Address = "$MYSQL_DB_HOST"
  DB Port = "$MYSQL_DB_PORT"
  DB User = "$MYSQL_DB_USER"
  DB PASSWORD = "$MYSQL_DB_PASSWORD"
}

Catalog {
  Name = MyCatalog-new
  DB Driver = "postgresql"
  DB Name = "$PGSQL_DB_NAME"
  DB Address = "$PGSQL_DB_HOST"
  DB Port = "$PGSQL_DB_PORT"
  DB User = "$PGSQL_DB_USER"
  DB Password = "$PGSQL_DB_PASSWORD"
}
EOF

cat << EOF > /etc/mysql.cnf
[client]
user = "${MYSQL_DB_USER}"
password = "${MYSQL_DB_PASSWORD}"
EOF

# MySQL backup
date=$(date +%s)
mysqldump --defaults-extra-file=/etc/mysql.cnf --column-statistics=0  \
	-h ${MYSQL_DB_HOST} ${MYSQL_DB_NAME} > /backup/bareos-${date}.sql

if [ $? -eq 0 ] ; then
  echo "[!] MySQL dump ok"
else
  echo "[!] MySQL dump failed"
fi

# Start Bareos DB copy
su -s /bin/bash - bareos -c "bareos-dbcopy MyCatalog MyCatalog-new"

#while [ true ] ; do 
#  echo "$(date) End" ; sleep 2
#done

#Run Dockerfile CMD
exec "$@"
