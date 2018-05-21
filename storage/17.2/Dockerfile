# Dockerfile BareOS storage daemon

FROM       barcus/ubuntu:xenial
MAINTAINER Barcus <barcus@tou.nu>

ENV DEBIAN_FRONTEND noninteractive

RUN curl -Ls http://download.bareos.org/bareos/release/17.2/xUbuntu_16.04/Release.key | apt-key --keyring /etc/apt/trusted.gpg.d/breos-keyring.gpg add - && \
    echo 'deb http://download.bareos.org/bareos/release/17.2/xUbuntu_16.04/ /' > /etc/apt/sources.list.d/bareos.list && \
    apt-get update -qq && \
    apt-get install -qq -y bareos-storage && \
    apt-clean

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-sd.tgz /etc/bareos/bareos-sd.d

EXPOSE 9103

VOLUME /etc/bareos
VOLUME /var/lib/bareos/storage

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-sd", "-u", "bareos", "-f"]
