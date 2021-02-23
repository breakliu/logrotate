FROM alpine:3.13

ENV CRON_SCHEDULE='0 * * * *'

RUN apk --no-cache add logrotate tini libintl procps

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/sbin/crond", "-f", "-L", "/dev/stdout"]
