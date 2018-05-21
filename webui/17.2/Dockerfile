# BareOS Web-ui Dockerfile
FROM       barcus/ubuntu:xenial
MAINTAINER Barcus <barcus@tou.nu>

ENV DEBIAN_FRONTEND noninteractive

RUN curl -Ls http://download.bareos.org/bareos/release/17.2/xUbuntu_16.04/Release.key | apt-key --keyring /etc/apt/trusted.gpg.d/breos-keyring.gpg add - && \
    echo 'deb http://download.bareos.org/bareos/release/17.2/xUbuntu_16.04/ /' > /etc/apt/sources.list.d/bareos.list && \
    apt-get update -qq && \
    apt-get install -qq -y bareos-webui && \
    apt-clean

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-webui.tgz /etc/bareos-webui

EXPOSE 80

VOLUME /etc/bareos-webui

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
