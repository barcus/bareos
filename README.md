## docker-bareos ![License badge][license-img] [![Build Status][build-img]][build-url] [![CircleCI][circleci-img]][circleci-url]

## About
This package provides images for [BareOS](http://www.bareos.org) :

module|pulls
-----|-----
Director| [![Docker badge][docker-img-dir]][docker-url-dir]
Storage Daemon| [![Docker badge][docker-img-sd]][docker-url-sd]
Client/File Daemon| [![Docker badge][docker-img-fd]][docker-url-fd]
webUI| [![Docker badge][docker-img-ui]][docker-url-ui]

It's based on Alpine (very small image) and BareOS Alpine package

You can find Ubuntu version [here](https://github.com/barcus/bareos)

BareOS Director require :
* MySQL as catalog backend
* SMTP Daemon as local mail router (backup reports)

BareOS Webui require :
* PHP-FPM

Each component runs in an single container and are linked together by docker-compose :
* :+1: Tested with BareOS 17.2

## Security advice
The default passwords inside the configuration files are created when building the docker image. Hence for production either build the image yourself using the sources from Github.

:o: Do not use this container for anything else, as passwords get expose to the BareOS containers.

## Setup
With docker-compose, you can find it [here](https://docs.docker.com/compose/)

A docker-compose file is available [here](https://github.com/barcus/bareos/blob/alpine/docker-compose.yml)

```bash
docker-compose -f /path/to/your/docker-compose.yml up -d
```

## Usage
When all containers are up and running :
* BareOS WebUI (with my docker-compose.yml) :

Open `http://your-docker-host:8080/` in your browser  (user: admin / pass: ThisIsMySecretUIp4ssw0rd )

* BaresOS bconsole :

```bash
docker exec -it bareos-dir bconsole
```

## Build
Build your own BareOS images :
```bash
git clone https://github.com/barcus/bareos
cd bareos
docker build director-mysql/17.2
docker build storage/17.2
docker build client/17.2
docker build webui/17.2
```

Build your own Ubuntu base system image :
```bash
git clone https://github.com/rockyluke/docker-ubuntu
cd docker-ubuntu
./build.sh -d xenial
```
Thanks to @rockyluke :)

Build your own Alpine base system image :
...soon :)

## Links
For more information visit the Github repositories :

* [bareos-director-mysql](https://github.com/barcus/bareos/tree/alpine/director-mysql)
* [bareos-director-pgsql](https://github.com/barcus/bareos/tree/alpine/director-pgsql)
* [bareos-storage](https://github.com/barcus/bareos/tree/alpine/storage)
* [bareos-client](https://github.com/barcus/bareos/tree/alpine/client)
* [bareos-webui](https://github.com/barcus/bareos/tree/alpine/webui)
* [php-fpm-alpine](https://github.com/barcus/docker-php-fpm-alpine)
* [docker-ubuntu](https://github.com/rockyluke/docker-ubuntu)

My Docker hub :
* [docker images](https://hub.docker.com/r/barcus)

Enjoy !

[license-img]: https://img.shields.io/badge/license-ISC-blue.svg
[build-img]: https://travis-ci.org/barcus/bareos.svg?branch=alpine
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
