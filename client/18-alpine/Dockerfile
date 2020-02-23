# Dockerfile Bareos client/file daemon
ARG	   BASE_ARCH=amd64
FROM       ${BASE_ARCH}/alpine:3.10
MAINTAINER Barcus <barcus@tou.nu>

RUN set -ex \
    && apk add --no-cache bareos openssh-client curl

RUN curl -OL https://github.com/multiarch/qemu-user-static/releases/download/v3.1.0-2/qemu-arm-static -o /usr/bin/qemu-arm-static && \
    chmod +x /usr/bin/qemu-arm-static
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-fd.tgz /etc/bareos/bareos-fd.d
RUN mkdir /run/bareos
RUN chown bareos /run/bareos

EXPOSE 9102

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-fd", "-u", "bareos", "-f"]
