FROM alpine:latest
EXPOSE 67/tcp 67/udp
RUN apk add --no-cache kea-dhcp4
RUN mkdir /run/kea && mkdir -p /etc/kea
RUN touch /run/kea/logger_lockfile
CMD ["/usr/sbin/kea-dhcp4", "-c", "/etc/kea/kea-dhcp4.conf"]
