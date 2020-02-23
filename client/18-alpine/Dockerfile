# Dockerfile Bareos client/file daemon
ARG	   BASE_ARCH=amd64
FROM       ${BASE_ARCH}/alpine:3.10
MAINTAINER Barcus <barcus@tou.nu>

COPY qemu-aarch64-static /usr/bin

RUN set -ex \
    && apk add --no-cache bareos openssh-client curl

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-fd.tgz /etc/bareos/bareos-fd.d
RUN mkdir /run/bareos
RUN chown bareos /run/bareos

EXPOSE 9102

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-fd", "-u", "bareos", "-f"]
