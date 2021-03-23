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

Images are based on **Ubuntu** or **Alpine**, check tags below

:+1: Tested with Bareos 16.x.x to 20.0.0

:warning: MySQL/MariaDB backends deprecated since Bareos 19.0.0

:warning: SQLite backend deprecated since Bareos 20.0.0

* Ubuntu images for Bareos 16 and 17 are based on **Xenial**
* Ubuntu images for Bareos 18 and 19 are based on **Bionic**
* Ubuntu images for Bareos 20 are based on **Focal**
* Alpine images are available for **linux/amd64** and **linux/arm64/v8** platform

## Tags

bareos-director (dir)

* `20-ubuntu-mysql`
* `20-ubuntu-pqsql`, `20-ubuntu`, `20`, `ubuntu`, `latest`
* `19-ubuntu-mysql`, `19-ubuntu`, `19`
* `19-ubuntu-pqsql`
* `19-alpine-mysql`, `19-alpine`, `alpine`
* `19-alpine-pgsql`
* `18-ubuntu-mysql`, `18-ubuntu`, `18`
* `18-ubuntu-pgsql`
* `18-alpine-mysql`, `18-alpine`
* `17-ubuntu-mysql`, `17-ubuntu`, `17`
* `17-ubuntu-pgsql`
* `17-alpine`
* `16-ubuntu-mysql`, `16-ubuntu`, `16`
* `16-ubuntu-pgsql`

bareos-client (fd) - bareos-storage (sd) - bareos-webui

* `20-ubuntu`, `20`, `ubuntu`, `latest`
* `19-ubuntu`, `19`
* `19-alpine`, `alpine`
* `18-ubuntu`, `18`
* `18-alpine`
* `17-ubuntu`, `17`
* `17-alpine`
* `16-ubuntu`, `16`

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

Bareos Client (fd) and Storage (sd) have no depencies.

Each component have to run in an single container and must linked together
through docker-compose, see exemple below

## Requirements

* [Docker][docker-href] & [docker-compose][docker-compose-href]

## Usage

Declare environment variables or copy the `.env.dist` to `.env` and adjust its values.

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

Remember to change your mail address in `ADMIN_MAIL` and maybe some passwords :grin:

:file_folder: Those docker-compose file are configured to store data inside
`/data/(bareos|mysql|pgsql)`

Finaly, when your containers are up and runing access Bareos through

* WebUI :

Open `http://your-docker-host:8080` (user: admin / pass: `<BAREOS_WEBUI_PASSWORD>`)

* bconsole :

Run `docker exec -it bareos-dir bconsole`

## Build

### Docker-compose file

Build your own docker-compose file with this template :

```yml
version: '3'
services:
  bareos-dir:
    image: barcus/bareos-director:latest #latest dicector+mysql based on ubuntu
    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos
      - <BAREOS_DATA_PATH>:/var/lib/bareos #required for MyCatalog backup
    environment:
      - DB_PASSWORD=ThisIsMySecretDBp4ssw0rd
      - DB_HOST=bareos-db
      - DB_PORT=3306
      - BAREOS_FD_HOST=bareos-fd
      - BAREOS_SD_HOST=bareos-sd
      - BAREOS_FD_PASSWORD=ThisIsMySecretFDp4ssw0rd
      - BAREOS_SD_PASSWORD=ThisIsMySecretSDp4ssw0rd
      - BAREOS_WEBUI_PASSWORD=ThisIsMySecretUIp4ssw0rd
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
      - BAREOS_SD_PASSWORD=ThisIsMySecretSDp4ssw0rd

  bareos-fd:
    image: barcus/bareos-client:latest
    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos
      - <BAREOS_DATA_PATH>:/var/lib/bareos-director #required for MyCatalog backup
    environment:
      - BAREOS_FD_PASSWORD=ThisIsMySecretFDp4ssw0rd
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

  bareos-db:
    image: mysql:5.6
    volumes:
      - <DB_DATA_PATH>:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=ThisIsMySecretDBp4ssw0rd

  #bareos-db:
  #  image: postgres:9.3
  #  volumes:
  #    - <DB_DATA_PATH>:/var/lib/postgresql/data
  #  environment:
  #    - POSTGRES_PASSWORD=ThisIsMySecretDBp4ssw0rd

  smtpd:
    image: namshi/smtp
```

**Bareos Director** (bareos-dir)

* `<BAREOS_CONF_PATH>` is the path to share your Director config folder from
 the host side (optional/recommended)
* `<BAREOS_DATA_PATH>` is the path to share your Director data folder from
 the host side (recommended)
* DB_PASSWORD must be same as Bareos Database section
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
docker build -t director-mysql:18-alpine director-mysql/18-alpine
docker build -t storage:18-alpine storage/18-alpine
docker build -t client:18-alpine client/18-alpine
docker build -t webui:18-alpine webui/18-alpine
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
[compose-alpinev1-href]: https://github.com/barcus/bareos/blob/master/docker-compose-alpine-v1.yml
[compose-alpinev2-href]: https://github.com/barcus/bareos/blob/master/docker-compose-alpine-v2.yml
[compose-ubuntu-mysql-href]: https://github.com/barcus/bareos/blob/master/docker-compose-ubuntu-mysql.yml
[compose-ubuntu-pgsql-href]: https://github.com/barcus/bareos/blob/master/docker-compose-ubuntu-pgsql.yml
[docker-compose-href]: https://docs.docker.com/compose
[docker-href]: https://docs.docker.com/install
[docker-img-dir]: https://img.shields.io/docker/pulls/barcus/bareos-director?label=bareos-director&logo=docker
[docker-img-fd]: https://img.shields.io/docker/pulls/barcus/bareos-client?label=bareos-client&logo=docker
[docker-img-sd]: https://img.shields.io/docker/pulls/barcus/bareos-storage?label=bareos-storage&logo=docker
[docker-img-ui]: https://img.shields.io/docker/pulls/barcus/bareos-webui?label=bareos-webui&logo=docker
[docker-url-dir]: https://registry.hub.docker.com/r/barcus/bareos-director
[docker-url-fd]: https://registry.hub.docker.com/r/barcus/bareos-client
[docker-url-sd]: https://registry.hub.docker.com/r/barcus/bareos-storage
[docker-url-ui]: https://registry.hub.docker.com/r/barcus/bareos-webui
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
[run-compose-png]: https://github.com/barcus/bareos/workflows/run-compose/badge.svg
