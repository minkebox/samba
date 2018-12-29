FROM alpine:edge

RUN apk --no-cache add samba-server inotify-tools avahi
RUN rm -f /etc/avahi/services/*.service
COPY overlay/ /

EXPOSE 137/udp 138/udp 139/tcp 445/tcp
VOLUME /shareable

ENTRYPOINT ["/startup.sh"]
