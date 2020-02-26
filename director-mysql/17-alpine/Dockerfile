# Bareos director Dockerfile
FROM       alpine:3.8
MAINTAINER Barcus <barcus@tou.nu>

RUN apk add --no-cache bareos mysql-client curl

COPY docker-entrypoint.sh /
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-dir.tgz /etc/bareos
RUN mkdir /run/bareos
RUN chown bareos /run/bareos

EXPOSE 9101

VOLUME /etc/bareos
VOLUME /var/lib/bareos

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-dir", "-u", "bareos", "-f"]
