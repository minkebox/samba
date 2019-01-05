FROM alpine:edge

RUN apk --no-cache add samba-server inotify-tools

COPY overlay/ /

EXPOSE 137/udp 138/udp 139/tcp 445/tcp
VOLUME /shareable

ENTRYPOINT ["/startup.sh"]
