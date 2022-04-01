# bareos

![License badge][license-img]
![Based OS][os-based-ubuntu] ![Based OS][os-based-alpine]
![Badge amd64][arch-amd64-img] ![Badge arm64][arch-arm64/v8-img]

## About

This package provides images for [Bareos][bareos-href] :

| module | build | size ubuntu | size alpine | pull |
|:-------------------:|:------------------------------------------------------------:|:---------------------------------------:|:---------------------------------------:|:-------------------------------------------------:|
| Director | [![Actions Status][build-director-img]][build-director-href] | ![Size badge][size-latest-director-png] | ![Size badge][size-alpine-director-png] | [![Docker badge][docker-img-dir]][docker-url-dir] |
| Storage Daemon | [![Actions Status][build-storage-img]][build-storage-href] | ![Size badge][size-latest-storage-png] | ![Size badge][size-alpine-storage-png] | [![Docker badge][docker-img-sd]][docker-url-sd] |
| Client/File Daemon | [![Actions Status][build-client-img]][build-client-href] | ![Size badge][size-latest-client-png] | ![Size badge][size-alpine-client-png] | [![Docker badge][docker-img-fd]][docker-url-fd] |
| webUI | [![Actions Status][build-webui-img]][build-webui-href] | ![Size badge][size-latest-webui-png] | ![Size badge][size-alpine-webui-png] | [![Docker badge][docker-img-ui]][docker-url-ui] |
| API | [![Actions Status][build-api-img]][build-api-href] | ![Size badge][size-latest-api-png] | | [![Docker badge][docker-img-api]][docker-url-api] |

Images are based on **Ubuntu** or **Alpine**, check tags below

:+1: Tested with Bareos 16.x.x to 21.0.0

:warning:

* MySQL/MariaDB backend deprecated since Bareos 20.0.0 (available for old DB only)
* MySQL/MariaDB backend not available since Bareos 21.0.0
* SQLite backend deprecated since Bareos 20.0.0

* Ubuntu images for Bareos 16 and 17 are based on **Xenial** (deprecated)
* Ubuntu images for Bareos 18 and 19 are based on **Bionic**
* Ubuntu images for Bareos 20 and 21 are based on **Focal**
* Alpine images are available for **linux/amd64** and **linux/arm64/v8** platform
* Weekly build are deployed to [Docker hub][docker-url] on Sunday 4am (GMT+1)

## Tags

bareos-director (dir)

* `nightly`
* `21-ubuntu-pgsql`, `21-ubuntu`, `21`, `ubuntu`, `latest`
* `20-ubuntu-pgsql`, `20-ubuntu`, `20`
* `20-ubuntu-mysql`
* `20-alpine-pgsql`, `20-alpine`, `alpine`
* `19-ubuntu-mysql`, `19-ubuntu`, `19`
* `19-ubuntu-pgsql`
* `19-alpine-mysql`, `19-alpine`
* `19-alpine-pgsql`
* `18-ubuntu-mysql`, `18-ubuntu`, `18`
* `18-ubuntu-pgsql`
* `18-alpine-mysql`, `18-alpine`

:warning: Deprecated images

* `17-ubuntu-mysql`, `17-ubuntu`, `17`
* `17-ubuntu-pgsql`
* `17-alpine`
* `16-ubuntu-mysql`, `16-ubuntu`, `16`
* `16-ubuntu-pgsql`

bareos-client (fd) - bareos-storage (sd) - bareos-webui

* `nightly`
* `21-ubuntu`, `21`, `ubuntu`, `latest`
* `20-ubuntu`, `20`
* `20-alpine`, `alpine`
* `19-ubuntu`, `19`
* `19-alpine`
* `18-ubuntu`, `18`
* `18-alpine`

:warning: Deprecated images

* `17-ubuntu`, `17`
* `17-alpine`
* `16-ubuntu`, `16`

bareos-api

* `21-alpine`, `21`, `alpine`, `latest`

## Security advice

The default passwords inside the configuration files are created when building
the docker image. Hence for production either build the image yourself using
the sources from Github.

:o: Do not use this container for anything else, as passwords get expose to
the Bareos containers.

## Setup

Bareos Director requires :

* PostgreSQL or MySQL as a catalog backend (MySQL deprecated since Bareos 19.0.0)
* SMTP Daemon as mail router (for reporting)

Bareos Webui requires (Alpine images only) :

* PHP-FPM

Bareos Client (fd) and Storage (sd) have no dependencies.

Each component have to run in an single container and must linked together
through docker-compose, see example below

## Requirements

* [Docker][docker-href] & [docker-compose][docker-compose-href]

## Usage

Declare environment variables or copy the `.env.dist` to `.env` and adjust its
values.

Remember that all passwords should be defined inside this `.env` file.
Feel free to change some passwords after your test also don't forget to update
`ADMIN_MAIL` varialble in docker-compose file.

```bash
docker-compose -f /path/to/your/docker-compose.yml up -d
```

docker-compose files are available for Alpine and Ubuntu based stack:

| file | compose | docker | latest build |
|:-----------------------------------------:|:-------:|:---------:|:-------------------------------:|
| [alpine-v1/mysql][compose-alpinev1-href] | v3+ | v1.13.0+ | ![run-compose][run-compose-png] |
| [alpine-v2/mysql][compose-alpinev2-href] | v3.7+ | v18.06.0+ | ![run-compose][run-compose-png] |
| [ubuntu/mysql][compose-ubuntu-mysql-href] | v3+ | v1.13.0+ | ![run-compose][run-compose-png] |
| [ubuntu/pgsql][compose-ubuntu-pgsql-href] | v3+ | v1.13.0+ | ![run-compose][run-compose-png] |

:file_folder: Those docker-compose file are configured to store data inside
`/data/(bareos|mysql|pgsql)`

Finally, when your containers are up and running access Bareos through

=> WebUI : (user: admin / pass: `<BAREOS_WEBUI_PASSWORD>`)

Open `http://your-docker-host:8080` then sign-in

=> bconsole :

Run `docker exec -it bareos-dir bconsole`

=> API : (Required Bareos 20+ and Bareos named console)

Open `http://your-docker-host:8000/docs` then click 'Authorize' to sign-in or
use curl as example below

Get token: (should return json object with token inside)

```bash
curl -X 'POST' \
  'http://your-docker-host:8000/token' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=&username=admin&password=ThisIsMySecretUIp4ssw0rd&scope=&client_id=&client_secret='
```

As you can see it uses credentials of Bareos-webui admin user which is
configure as a named console in Bareos-director.

Result:

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTY0NzIxMDM3NX0.alKiLsgMrovKVX6fdcUqkhG_9lsJNiOBQ6X7ixyziGw",
  "token_type": "bearer"
}
```

Then, use this token for example to read all clients configuration (like in bconsole)

```bash
curl -X 'GET' \
  'http://your-docker-host:8000/configuration/clients?verbose=yes' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTY0NzIxMDM3NX0.alKiLsgMrovKVX6fdcUqkhG_9lsJNiOBQ6X7ixyziGw'
```

More information about Bareos configuration and usage in the [official documantion][bareos-doc]

### Database migration (MySQL to PostgreSQL)

Since Bareos Version >= 21.0.0 the MySQL database backend is not shipped
anymore. Therefore you need to use Bareos 20 to migrate an existing MySQL
Bareos Catalog to PostgreSQL. To do so, upgrade to Bareos 20 first and then
use [this docker-compose file][compose-db-migration-href] to backup
(optional) the whole Bareos MySQL catalog and copy it into a new PostgreSQL
catalog database.

If PostgreSQL database is empty or does not exist, it will be created.

:warning: Don't forget `.env` file with passwords required!

### PostgreSQL database upgrade

#### Compatibility

At this moment, latest Ubuntu based images are compliant with PostgreSQL 12 or
less and Alpine ones with PostgreSQL 14. This is due to the version of `pg_dump`
which is required to dump Bareos database.

Ubuntu images:

* Bareos v19 -> PostgreSQL v10 or less
* Bareos v20+ -> PostgreSQL v12 or less

Alpine images:

* Bareos v19 -> PostgreSQL v13 or less
* Bareos v20+ -> PostgreSQL v14 or less

### Tool

The main idea here is to use [postgresql-upgrade][psql-upgrade-href] Docker
image. It will create a new PostgreSQL instance and then use `pg_upgrade`
tool to move all databases from the old instance to the new one.

To proceed, locate your PostgreSQL data folder, according our own docker
compose files it could be /data/pgsql/data ! Then identify user used to init
the instance. postgres ? pgsql ? root ?

Let's try an exemple with data source `/data/pgsql/data` and postgres
as an admin user.

Finaly run:

```bash
docker run -t -i \
  -e PG_NEW=12 \
  -e PGUSER=postgres \
  -v /data/pgsql/data:/pg_old/data \
  -v /data/pgsql-new/data:/pg_new/data \
  barcus/postgresql-upgrade
```

After sucessful migration, use the new folder `/data/pgsql-new/data` and the
PostgreSQL version related in your docker-compose file.

## Build

### Docker-compose file

Build your own docker-compose file with this template :

```yml
version: '3'
services:
  bareos-dir:
    image: barcus/bareos-director:latest #latest director-pgsql based on ubuntu
    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos
      - <BAREOS_DATA_PATH>:/var/lib/bareos #required for MyCatalog backup
    environment:
      - DB_INIT=false
      - DB_UPDATE=false
      - DB_HOST=bareos-db
      - DB_PORT=3306
      - DB_NAME=bareos
      - DB_USER=bareos
      - DB_PASSWORD=${DB_PASSWORD} # defined in .env file
      - DB_ADMIN_USER=${DB_ADMIN_USER} # defined in .env file
      - DB_ADMIN_PASSWORD=${DB_ADMIN_PASSWORD} # defined in .env file
      - BAREOS_FD_HOST=bareos-fd
      - BAREOS_FD_PASSWORD=${BAREOS_FD_PASSWORD} # defined in .env file
      - BAREOS_SD_HOST=bareos-sd
      - BAREOS_SD_PASSWORD=${BAREOS_SD_PASSWORD} # defined in .env file
      - BAREOS_WEBUI_PASSWORD=${BAREOS_WEBUI_PASSWORD} # defined in .env file
      - SMTP_HOST=smtpd
      - SENDER_MAIL=your-sender@mail.address #optional
      - ADMIN_MAIL=your@mail.address # Change me!
      # Optional you can get backup notification via Slack or Telegram
      - WEBHOOK_NOTIFICATION=true # true or false if set to true email notification gets disabled
      - WEBHOOK_TYPE=slack # choose slack or telegram
      - WEBHOOK_URL= # set the slack or telegram URL
      - WEBHOOK_CHAT_ID= # for telegram only set the <chat_id>
    depends_on:
      - bareos-db

  bareos-sd:
    image: barcus/bareos-storage:latest
    ports:
      - 9103:9103
    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos
      - <BAREOS_BKP_VOLUME_PATH>:/var/lib/bareos/storage
    environment:
      - BAREOS_SD_PASSWORD=${BAREOS_SD_PASSWORD} # defined in .env file

  bareos-fd:
    image: barcus/bareos-client:latest
    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos
      - <BAREOS_DATA_PATH>:/var/lib/bareos-director #required for MyCatalog backup
    environment:
      - BAREOS_FD_PASSWORD=${BAREOS_FD_PASSWORD} # defined in .env file
      - FORCE_ROOT=false

  bareos-webui:
    image: barcus/bareos-webui:latest
    ports:
      - 8080:80
    environment:
      - BAREOS_DIR_HOST=bareos-dir
      - SERVER_STATS=yes #optional enable apache server statistics
    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos-webui

  #bareos-db:
  #  image: mysql:5.6
  #  volumes:
  #    - <DB_DATA_PATH>:/var/lib/mysql
  #  environment:
  #    - MYSQL_ROOT_PASSWORD=${DB_ADMIN_PASSWORD} # defined in .env file

  bareos-db:
    image: postgres:12
    volumes:
      - <DB_DATA_PATH>:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=${DB_ADMIN_USER} # defined in .env file
      - POSTGRES_PASSWORD=${DB_ADMIN_PASSWORD} # defined in .env file
      - POSTGRES_INITDB_ARGS=--encoding=SQL_ASCII

  bareos-api:
    image: barcus/bareos-api:21
    ports:
    - 8000:8000
    environment:
    - BAREOS_DIR_HOST=bareos-dir

  smtpd:
    image: namshi/smtp
```

**Bareos Director** (bareos-dir)

* `<BAREOS_CONF_PATH>` is the path to share your Director config folder from
 the host side (optional/recommended)
* `<BAREOS_DATA_PATH>` is the path to share your Director data folder from
 the host side (recommended)
* DB_NAME is the bareos database name
* DB_USER is the bareos database user
* DB_PASSWORD is the password use to access to the bareos database
* DB_ADMIN_USER is the password use to initialize bareos user and database
* DB_ADMIN_PASSWORD is the password use to access to database system
* SMTP_HOST is the name of smtp container
* ADMIN_MAIL is your email address
* SENDER_MAIL is the email address you want to use for send the email
 (optional, default ADMIN_MAIL value)
* WEBHOOK_NOTIFICATION=true # true or false if set to true email notification gets disabled
* WEBHOOK_TYPE=slack # choose slack or telegram
* WEBHOOK_URL= # set the slack or telegram URL (ex slack: <https://hooks.slack.com/services/TXXXXXXXXXX/XXXXXXXXXXX/Cbzi0lUVjKsjiM6kjZL2eQAW>)
* WEBHOOK_CHAT_ID= # for telegram only set the 'chat_id'

**Bareos Storage Daemon** (bareos-sd)

* `<BAREOS_CONF_PATH>` is the path to share your Storage config folder from
 the host side (optional/recommended)
* `<BAREOS_BKP_VOLUME_PATH>` is the path to share your data folder from the
 host side. (optional)
* BAREOS_SD_PASSWORD must be same as Bareos Director section

**Bareos Client/File Daemon** (bareos-fd)

* `<BAREOS_CONF_PATH>` is the path to share your Client config folder from the
 host side (optional/recommended)
* `<BAREOS_DATA_PATH>` is the path to access Director data folder (recommended)
* BAREOS_FD_PASSWORD must be same as Bareos Director section
* FORCE_ROOT must be true to run Bareos with root permissions

**Database MySQL or PostgreSQL** (bareos-db)

Required as catalog backend, simply use the official MySQL/PostgreSQL image

* `<DB_DATA_PATH>` is the path to share your MySQL/PostgreSQL data from the host
 side
* MYSQL_ROOT_PASSWORD is the password for MySQL root user (required for DB init only)
* POSTGRES_PASSWORD is the password for PostgreSQL root user (required for DB init only)

**Bareos webUI** (bareos-webui)

* `<BAREOS_CONF_PATH>` is the path to share your WebUI config folder from the
 host side. (optional)
* default user is `admin`

:warning: Remember variables `*_HOST` must be set with container name

### Your own Docker images

Build your own Bareos images :

```bash
git clone https://github.com/barcus/bareos
cd bareos
docker build -t director-pqsl:20-alpine director-pgsql/20-alpine
docker build -t storage:20-alpine storage/20-alpine
docker build -t client:20-alpine client/20-alpine
docker build -t webui:20-alpine webui/20-alpine
```

Build your own Xenial base system image :

```bash
git clone https://github.com/rockyluke/docker-ubuntu
cd docker-ubuntu
./build.sh -d xenial
```

Thanks to @rockyluke :)

## Links

For more information visit the Github repositories :

* [bareos-director-mysql](https://github.com/barcus/bareos/tree/master/director-mysql)
* [bareos-director-pgsql](https://github.com/barcus/bareos/tree/master/director-pgsql)
* [bareos-storage](https://github.com/barcus/bareos/tree/master/storage)
* [bareos-client](https://github.com/barcus/bareos/tree/master/client)
* [bareos-webui](https://github.com/barcus/bareos/tree/master/webui)
* [docker-ubuntu](https://github.com/rockyluke/docker-ubuntu)

My Docker hub :

* [docker images](https://hub.docker.com/r/barcus)

Enjoy !

[arch-amd64-img]: https://img.shields.io/badge/arch-amd64-inactive
[arch-arm64/v8-img]: https://img.shields.io/badge/arch-arm64/v8-inactive
[bareos-href]: https://www.bareos.org
[bareos-doc]: https://www.bareos.com/learn/documentation
[build-client-href]: https://github.com/barcus/bareos/actions?query=workflow%3Aci-client
[build-client-img]: https://github.com/barcus/bareos/workflows/ci-client/badge.svg
[build-director-href]: https://github.com/barcus/bareos/actions?query=workflow%3Aci-director
[build-director-img]: https://github.com/barcus/bareos/workflows/ci-director/badge.svg
[build-img]: https://travis-ci.org/barcus/bareos.svg?branch=master
[build-storage-href]: https://github.com/barcus/bareos/actions?query=workflow%3Aci-storage
[build-storage-img]: https://github.com/barcus/bareos/workflows/ci-storage/badge.svg
[build-url]: https://travis-ci.org/barcus/bareos
[build-webui-href]: https://github.com/barcus/bareos/actions?query=workflow%3Aci-webui
[build-webui-img]: https://github.com/barcus/bareos/workflows/ci-webui/badge.svg
[build-api-href]: https://github.com/barcus/bareos/actions?query=workflow%3Aci-api
[build-api-img]: https://github.com/barcus/bareos/workflows/ci-api/badge.svg
[compose-alpinev1-href]: https://github.com/barcus/bareos/blob/master/docker-compose-alpine-v1.yml
[compose-alpinev2-href]: https://github.com/barcus/bareos/blob/master/docker-compose-alpine-v2.yml
[compose-ubuntu-mysql-href]: https://github.com/barcus/bareos/blob/master/docker-compose-ubuntu-mysql.yml
[compose-ubuntu-pgsql-href]: https://github.com/barcus/bareos/blob/master/docker-compose-ubuntu-pgsql.yml
[compose-db-migration-href]: https://github.com/barcus/bareos/blob/master/bareos-db-migration/docker-compose.yml
[docker-compose-href]: https://docs.docker.com/compose
[docker-href]: https://docs.docker.com/install
[docker-img-dir]: https://img.shields.io/docker/pulls/barcus/bareos-director?label=bareos-director&logo=docker
[docker-img-fd]: https://img.shields.io/docker/pulls/barcus/bareos-client?label=bareos-client&logo=docker
[docker-img-sd]: https://img.shields.io/docker/pulls/barcus/bareos-storage?label=bareos-storage&logo=docker
[docker-img-ui]: https://img.shields.io/docker/pulls/barcus/bareos-webui?label=bareos-webui&logo=docker
[docker-img-api]: https://img.shields.io/docker/pulls/barcus/bareos-api?label=bareos-api&logo=docker
[docker-url]: https://registry.hub.docker.com/r/barcus
[docker-url-dir]: https://registry.hub.docker.com/r/barcus/bareos-director
[docker-url-fd]: https://registry.hub.docker.com/r/barcus/bareos-client
[docker-url-sd]: https://registry.hub.docker.com/r/barcus/bareos-storage
[docker-url-ui]: https://registry.hub.docker.com/r/barcus/bareos-webui
[docker-url-api]: https://registry.hub.docker.com/r/barcus/bareos-api
[license-img]: https://img.shields.io/badge/License-MIT-yellow.svg
[os-based-alpine]: https://img.shields.io/badge/os-alpine-9cf
[os-based-ubuntu]: https://img.shields.io/badge/os-ubuntu-9cf
[size-alpine-client-png]: https://img.shields.io/docker/image-size/barcus/bareos-client/alpine?label=alpine&style=plastic
[size-alpine-director-png]: https://img.shields.io/docker/image-size/barcus/bareos-director/alpine?label=alpine&style=plastic
[size-alpine-storage-png]: https://img.shields.io/docker/image-size/barcus/bareos-storage/alpine?label=alpine&style=plastic
[size-alpine-webui-png]: https://img.shields.io/docker/image-size/barcus/bareos-webui/alpine?label=alpine&style=plastic
[size-latest-client-png]: https://img.shields.io/docker/image-size/barcus/bareos-client/latest?label=latest&style=plastic
[size-latest-director-png]: https://img.shields.io/docker/image-size/barcus/bareos-director/latest?label=latest&style=plastic
[size-latest-storage-png]: https://img.shields.io/docker/image-size/barcus/bareos-storage/latest?label=latest&style=plastic
[size-latest-webui-png]: https://img.shields.io/docker/image-size/barcus/bareos-webui/latest?label=latest&style=plastic
[size-latest-api-png]: https://img.shields.io/docker/image-size/barcus/bareos-api/latest?label=latest&style=plastic
[run-compose-png]: https://github.com/barcus/bareos/workflows/run-compose/badge.svg
[psql-upgrade-href]: https://github.com/barcus/postgresql-upgrade
