FROM docker:stable

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk update \
 && apk add --no-cache curl bash git \
 && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
