# bareos

## About

This package provides images for Bareos database migratin from MySQL to
PostgreSQL.

## Tags

bareos-director (dir)

* `latest`

## Requirements

* [Docker][docker-href] & [docker-compose][docker-compose-href]

## Usage

Since Bareos Version >= 21.0.0 the MySQL database backend is not shipped
anymore. Therefore you need to use Bareos 20 to migrate an existing MySQL
Bareos Catalog to PostgreSQL. To do so, upgrade to Bareos 20 first and then
use [this docker-compose file][compose-db-migration-href] to backup
(optional) the whole Bareos MySQL catalog and copy it into a new PostgreSQL
catalog database.

If PostgreSQL database is empty or does not exist, it will be created.

Declare environment variables or copy the `.env.dist` to `.env` and adjust its
values.

Remember that all passwords should be defined inside this `.env` file.

If `DB_BACKUP` is set to true, MySQL database will be backup.

Read carefully this docker-compose file and update MySQL/PostgreSQL verion
if required. Check PostgreSQL compatibilty information below.

```bash
docker-compose -f docker-compose.yml up
```

After sucessful migration, use the new folder `/data/pgsql/data` and the
PostgreSQL version related in your docker-compose file.

### Compatibility

At this moment, latest Ubuntu based images are compliant with PostgreSQL 12 or
less and Alpine ones with PostgreSQL 14. This is due to the version of `pg_dump`
which is required to dump Bareos database (catalog).

Ubuntu images:

* Bareos v19 -> PostgreSQL v10 or less
* Bareos v20+ -> PostgreSQL v12 or less

Alpine images:

* Bareos v19 -> PostgreSQL v13 or less
* Bareos v20+ -> PostgreSQL v14 or less

## Links

For more information visit the Github repositories :

* [bareos-director-mysql](https://github.com/barcus/bareos/tree/master/director-mysql)
* [bareos-director-pgsql](https://github.com/barcus/bareos/tree/master/director-pgsql)
* [bareos-storage](https://github.com/barcus/bareos/tree/master/storage)
* [bareos-client](https://github.com/barcus/bareos/tree/master/client)
* [bareos-webui](https://github.com/barcus/bareos/tree/master/webui)
* [docker-ubuntu](https://github.com/rockyluke/docker-ubuntu)
* [postgresql-upgrade](https://github.com/barcus/postgresql-upgrade)

My Docker hub :

* [docker images](https://hub.docker.com/r/barcus)

Enjoy !

[compose-db-migration-href]: https://github.com/barcus/bareos/blob/master/bareos-db-migration/docker-compose.yml
[docker-compose-href]: https://docs.docker.com/compose
[docker-href]: https://docs.docker.com/install
