# Dockerfile BareOS storage daemon

FROM       barcus/ubuntu:trusty
MAINTAINER Barcus <barcus@tou.nu>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get install --no-install-recommends -y -qq wget \
  && bash -c 'wget -q http://download.bareos.org/bareos/release/latest/xUbuntu_14.04/Release.key -O- | apt-key add -' \
  && bash -c 'echo "deb http://download.bareos.org/bareos/release/latest/xUbuntu_14.04/ /" > /etc/apt/sources.list.d/bareos.list' \
  && bash -c "echo 'postfix postfix/main_mailer_type select No configuration' | debconf-set-selections" \
  && apt-get update \
  && apt-get install -y -qq --no-install-recommends bareos-storage \
  && apt-get -y -qq remove --purge wget \
  && apt-get -y -qq autoremove \
  && apt-get -y -qq clean \
  && apt-get -y -qq autoclean \
  && find /usr/share/doc     -type f ! -name copyright -delete \
  && find /usr/share/i18n    -type f -delete \
  && find /usr/share/locale  -type f -delete \
  && find /usr/share/man     -type f -delete \
  && find /var/cache/apt     -type f -delete \
  && find /var/lib/apt/lists -type f -delete

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-sd.tgz /etc/bareos/bareos-sd.d

EXPOSE 9103

VOLUME /etc/bareos
VOLUME /var/lib/bareos/storage

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-sd", "-u", "bareos", "-f"]
