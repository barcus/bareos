# Bareos Web-ui Dockerfile
FROM alpine:edge

RUN apk add --no-cache bareos-webui-nginx

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh
RUN tar cfvz /bareos-webui-config.tgz /etc/bareos-webui
RUN tar cfvz /bareos-webui-code.tgz /usr/share/bareos-webui
RUN mkdir /run/nginx

EXPOSE 9100

VOLUME /etc/bareos-webui

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
