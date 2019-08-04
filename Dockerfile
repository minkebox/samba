FROM alpine:latest

RUN apk add samba-server samba-common-tools python3

COPY root/ /

EXPOSE 137/udp 138/udp 139/tcp 445/tcp

ENTRYPOINT ["/startup.sh"]
