# Dockerfile Bareos storage daemon
FROM ubuntu:focal as build
WORKDIR /root
ARG VCHANGER="https://sourceforge.net/projects/vchanger/files/vchanger/1.0.3/vchanger-1.0.3.tar.gz/download"

RUN apt-get update -qq \
 && apt-get -qq -y install --no-install-recommends curl build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN curl -Lsk $VCHANGER -o vchanger.tar.gz \
 && tar -xzf vchanger.tar.gz

WORKDIR /root/vchanger

RUN ./configure \
 && make install-strip

FROM ubuntu:focal
LABEL maintainer="barcus@tou.nu"

ARG BUILD_DATE
ARG NAME
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$NAME \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/barcus/bareos" \
      org.label-schema.version=$VERSION

ENV BAREOS_KEY http://download.bareos.org/bareos/release/21/xUbuntu_20.04/Release.key
ENV BAREOS_REPO http://download.bareos.org/bareos/release/21/xUbuntu_20.04/
ENV DEBIAN_FRONTEND noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update -qq \
 && apt-get -qq -y install --no-install-recommends curl tzdata gnupg \
 && curl -Ls $BAREOS_KEY -o /tmp/bareos.key \
 && apt-key --keyring /etc/apt/trusted.gpg.d/breos-keyring.gpg \
    add /tmp/bareos.key \
 && echo "deb $BAREOS_REPO /" > /etc/apt/sources.list.d/bareos.list \
 && apt-get update -qq \
 && apt-get install -qq -y --no-install-recommends \
    bareos-storage bareos-tools bareos-storage-tape mtx scsitools \
    sg3-utils mt-st bareos-storage-droplet \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY --from=build /usr/local/bin/vchanger/ /usr/local/bin/vchanger/
COPY --from=build /usr/local/libexec/vchanger/ /usr/local/libexec/vchanger/
RUN chmod u+x /docker-entrypoint.sh

RUN tar czf /bareos-sd.tgz /etc/bareos/bareos-sd.d

EXPOSE 9103

VOLUME /etc/bareos
VOLUME /var/lib/bareos/storage

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-sd", "-u", "bareos", "-f"]
