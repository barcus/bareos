# Dockerfile Bareos client/file daemon
FROM alpine:3.12

LABEL maintainer="barcus@tou.nu"

ARG BUILD_DATE
ARG NAME
ARG VCS_REF
ARG VERSION

ENV BAREOS_DAEMON_USER bareos

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$NAME \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/barcus/bareos" \
      org.label-schema.version=$VERSION

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache bareos openssh-client tar

RUN tar czf /bareos-fd.tgz /etc/bareos/bareos-fd.d
RUN mkdir /run/bareos \
 && chown bareos /run/bareos

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh

EXPOSE 9102

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sh", "-c", "/usr/sbin/bareos-fd -u $BAREOS_DAEMON_USER -f"]
