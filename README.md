docker-php-fpm-alpine
=======
![License badge][license-img] [![Docker badge][docker-img]][docker-url]

## About
This package provides images for [php-fpm](http://php.net/manual/en/install.fpm.php) with some extra extentions installed :

* intl
* gettext

It's based on Alpine Edge.

## Setup

## Usage
```bash
docker run -t -i -v /website_dir:/var/www/html barcus/php-fpm-alpine
```

## Links
For more information visit the Github repositories :
* [php-fpm-alpine](https://github.com/barcus/php-fpm-alpine)

My Docker hub :
* [docker image](https://hub.docker.com/r/barcus/php-fpm-alpine)

Enjoy !

[license-img]: https://img.shields.io/badge/license-ISC-blue.svg
[docker-img]: https://img.shields.io/docker/pulls/barcus/php-fpm-alpine.svg
[docker-url]: https://registry.hub.docker.com/u/barcus/php-fpm-alpine
