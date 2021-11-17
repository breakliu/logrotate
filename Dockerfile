FROM alpine:3.14

ENV CRON_SCHEDULE='0 * * * *'

RUN echo "https://mirrors.tencent.com/alpine/v3.14/main/" > /etc/apk/repositories       && \
    echo "https://mirrors.tencent.com/alpine/v3.14/community/" >> /etc/apk/repositories && \
    apk --no-cache --update add tzdata logrotate tini                                   && \ 
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime                            && \
    echo Asia/Shanghai > /etc/timezone

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/sbin/crond", "-f", "-L", "/dev/stdout"]
