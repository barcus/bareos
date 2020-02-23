# Dockerfile Bareos client/file daemon

FROM       alpine:edge
MAINTAINER Barcus <barcus@tou.nu>

RUN set -ex \
    && apk add --no-cache bareos openssh-client

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-fd.tgz /etc/bareos/bareos-fd.d
RUN mkdir /run/bareos
RUN chown bareos /run/bareos

EXPOSE 9102

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-fd", "-u", "bareos", "-f"]
