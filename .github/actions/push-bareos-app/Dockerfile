FROM docker

RUN set -x \
 && apk update \
 && apk add --no-cache curl bash \
 && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
