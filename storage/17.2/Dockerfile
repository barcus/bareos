# Dockerfile BareOS storage daemon

FROM       alpine:edge
MAINTAINER Barcus <barcus@tou.nu>

RUN set -ex \
    && apk add --no-cache \
    bareos

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-sd.tgz /etc/bareos/bareos-sd.d
RUN mkdir /run/bareos
RUN chown bareos /run/bareos

EXPOSE 9103

VOLUME /etc/bareos
VOLUME /var/lib/bareos/storage

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-sd", "-u", "bareos", "-f"]
