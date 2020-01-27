# bareos

![License badge][license-img] [![Build Status][build-img]][build-url] [![CircleCI][circleci-img]][circleci-url]

## About

This package provides images for [Bareos][bareos-href] :

module|pulls
-----|-----
Director| [![Docker badge][docker-img-dir]][docker-url-dir]
Storage Daemon| [![Docker badge][docker-img-sd]][docker-url-sd]
Client/File Daemon| [![Docker badge][docker-img-fd]][docker-url-fd]
webUI| [![Docker badge][docker-img-ui]][docker-url-ui]

Images are based on Ubuntu or Alpine, check tags below

* :+1: Tested with Bareos 16.2, 17.2, 18.2 and 19.2rc1

## Tags

Director (bareos-dir)

* `19-mysql-ubuntu`, `19`
* `18-mysql-ubuntu`, `18-ubuntu`, `18`, `ubuntu`, `latest`
* `18-pgsql-ubuntu`
* `18-mysql-alpine`, `18-alpine`, `alpine`
* `17-mysql-ubuntu`, `17-ubuntu`, `17`
* `17-pgsql-ubuntu`
* `17-mysql-alpine`, `17-alpine`

Client (bareos-fd) - Storage (bareos-sd) - Webui

* `19-ubuntu`, `19`
* `18-ubuntu`, `18`, `ubuntu`, `latest`
* `18-alpine`, `alpine`
* `17-ubuntu`, `17`
* `17-alpine`

## Security advice

The default passwords inside the configuration files are created when building the docker image. Hence for production either build the image yourself using the sources from Github.

:o: Do not use this container for anything else, as passwords get expose to the Bareos containers.

## Setup

Bareos Director requires :

* PostgreSQL or MySQL as a catalog backend
* SMTP Daemon as mail router (for reporting)

Curently, PostgreSQL is not available on Alpine images.

Bareos Webui requires (Alpine images only) :

* PHP-FPM

Bareos Client (fd) and Storage (sd) have no depencies.

Each component have to run in an single container and must linked together through docker-compose, see exemple below

## Requirements

* [Docker][docker-href] & [docker-compose][docker-compose-href]

## Usage

```bash
docker-compose -f /path/to/your/docker-compose.yml up -d
```

docker-compose files are available for Alpine and Ubuntu based stack:

* [alpine/mysql](https://github.com/barcus/bareos/blob/master/docker-compose.yml) (compose v3.7, required Docker 18.06.0+)
* [alpine/mysql](https://github.com/barcus/bareos/blob/master/docker-compose-alpine.yml) (compose v3, required Docker 1.13.0+)
* [ubuntu/mysql](https://github.com/barcus/bareos/blob/master/docker-compose-mysql.yml) (compose v3, required Docker 1.13.0+)
* [ubuntu/pgsql](https://github.com/barcus/bareos/blob/master/docker-compose-pgsql.yml) (compose v3, required Docker 1.13.0+)

Remember to change your mail address in `ADMIN_MAIL` and maybe some passwords :grin:

:file_folder: Those docker-compose file are configured to store data inside `/data/(bareos|mysql|pgsql)`

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
    image: barcus/bareos-director:latest #(latest dicector+mysql based on ubuntu)

    volumes:
      - <BAREOS_CONF_PATH>:/etc/bareos
      - <BAREOS_DATA_PATH>:/var/lib/bareos # (required for MyCatalog backup)
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
      - <BAREOS_DATA_PATH>:/var/lib/bareos-director # (required for MyCatalog backup)
    environment:
      - BAREOS_FD_PASSWORD=ThisIsMySecretFDp4ssw0rd

  bareos-webui:
    image: barcus/bareos-webui:latest
    ports:
      - 8080:80
    environment:
      - BAREOS_DIR_HOST=bareos-dir
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

* `<BAREOS_CONF_PATH>` is the path to share your Director config folder from the host side (optional/recommended)
* `<BAREOS_DATA_PATH>` is the path to share your Director data folder from the host side (recommended)
* DB_PASSWORD must be same as Bareos Database section
* SMTP_HOST is the name of smtp container
* SENDER_MAIL is the email address you want to use for send the email # optional, if you don't specify it the ADMIN_MAIL will be used
* ADMIN_MAIL is your email address

**Bareos Storage Daemon** (bareos-sd)

* `<BAREOS_CONF_PATH>` is the path to share your Storage config folder from the host side (optional/recommended)
* `<BAREOS_BKP_VOLUME_PATH>` is the path to share your data folder from the host side. (optional)
* BAREOS_SD_PASSWORD must be same as Bareos Director section

**Bareos Client/File Daemon** (bareos-fd)

* `<BAREOS_CONF_PATH>` is the path to share your Client config folder from the host side (optional/recommended)
* `<BAREOS_DATA_PATH>` is the path to access Director data folder (recommended)
* BAREOS_FD_PASSWORD must be same as Bareos Director section

**Database MySQL or PostgreSQL** (bareos-db)

Required as catalog backend, simply use the official MySQL/PostgreSQL image

* `<DB_DATA_PATH>` is the path to share your MySQL/PostgreSQL data from the host side

**Bareos webUI** (bareos-webui)

* `<BAREOS_CONF_PATH>` is the path to share your WebUI config folder from the host side. (optional)
* default user is `admin`

:warning: Remember variables *_HOST must be set with container name

### Your own Docker images

Build your own Bareos images :

```bash
git clone https://github.com/barcus/bareos
cd bareos
docker build director-mysql/
docker build storage/
docker build client/
docker build webui/
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

[license-img]: https://img.shields.io/badge/license-ISC-blue.svg
[build-img]: https://travis-ci.org/barcus/bareos.svg?branch=master
[build-url]: https://travis-ci.org/barcus/bareos
[docker-img-dir]: https://img.shields.io/docker/pulls/barcus/bareos-director.svg
[docker-url-dir]: https://registry.hub.docker.com/u/barcus/bareos-director
[docker-img-sd]: https://img.shields.io/docker/pulls/barcus/bareos-storage.svg
[docker-url-sd]: https://registry.hub.docker.com/u/barcus/bareos-storage
[docker-img-fd]: https://img.shields.io/docker/pulls/barcus/bareos-client.svg
[docker-url-fd]: https://registry.hub.docker.com/u/barcus/bareos-client
[docker-img-ui]: https://img.shields.io/docker/pulls/barcus/bareos-webui.svg
[docker-url-ui]: https://registry.hub.docker.com/u/barcus/bareos-webui
[circleci-url]: https://circleci.com/gh/barcus/bareos
[circleci-img]: https://circleci.com/gh/barcus/bareos.svg?style=svg
[bareos-href]: https://www.bareos.org
[compose-file]: https://github.com/barcus/bareos/blob/master/docker-compose.yml
[docker-compose-href]: https://docs.docker.com/compose
[docker-href]: https://docs.docker.com/install
