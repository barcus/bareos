FROM docker

RUN set -x \
    && apk update \
    && apk add curl bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
