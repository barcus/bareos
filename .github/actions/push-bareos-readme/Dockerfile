FROM docker

RUN set -x \
    && apk update \
    && apk add bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
