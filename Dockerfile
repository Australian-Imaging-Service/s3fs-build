FROM debian:buster-slim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
  s3fs supervisor \
  && rm -rf /var/lib/apt/lists/*

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

LABEL maintainer="DeanTaylor@uwa.edu.au"
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
