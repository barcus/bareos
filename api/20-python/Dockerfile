FROM python:alpine AS bareos-api

LABEL maintainer="Maksim Kramarenko <mc.sim@k-max.name>"

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh

WORKDIR /opt

EXPOSE 8000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["uvicorn","--log-level", "warning", "--host", "0.0.0.0", "bareos-restapi:app", "--reload"]

