# BareOS director Dockerfile
FROM       tripax/ubuntu:trusty
MAINTAINER Barcus <barcus@tou.nu>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get install --no-install-recommends -y -qq wget postgresql-client \
  && bash -c 'wget -q http://download.bareos.org/bareos/release/latest/xUbuntu_14.04/Release.key -O- | apt-key add -' \
  && bash -c 'echo "deb http://download.bareos.org/bareos/release/latest/xUbuntu_14.04/ /" > /etc/apt/sources.list.d/bareos.list' \
  && bash -c "echo 'bareos-database-common bareos-database-common/dbconfig-install boolean false' | debconf-set-selections" \
  && bash -c "echo 'bareos-database-common bareos-database-common/install-error select ignore' | debconf-set-selections" \
  && bash -c "echo 'bareos-database-common bareos-database-common/database-type select psql' | debconf-set-selections" \
  && bash -c "echo 'bareos-database-common bareos-database-common/missing-db-package-error select ignore' | debconf-set-selections" \
  && bash -c "echo 'postfix postfix/main_mailer_type select No configuration' | debconf-set-selections" \
  && apt-get update \
  && apt-get install --no-install-recommends -y -qq bareos \
  && apt-get -y -qq clean \
  && apt-get -y -qq autoclean \
  && find /usr/share/doc     -type f ! -name copyright -delete \
  && find /usr/share/i18n    -type f -delete \
  && find /usr/share/locale  -type f -delete \
  && find /usr/share/man     -type f -delete \
  && find /var/cache/apt     -type f -delete \
  && find /var/lib/apt/lists -type f -delete

COPY docker-entrypoint.sh /
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-dir.tgz /etc/bareos

EXPOSE 9101

VOLUME /etc/bareos

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-dir", "-u", "bareos", "-f"]
