FROM centos:7

# set locale
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"

RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 && \
    echo 'LANG="ja_JP.UTF-8"' >  /etc/locale.conf && \
    echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock && \
    unlink /etc/localtime && \
    ln -s /usr/share/zoneinfo/Japan /etc/localtime

# install bind
RUN yum -y -q install bind bind-utils && \
    yum -q clean all

COPY named.conf /etc/named.conf
COPY data/ /var/named/data/

# log
RUN mkdir -p /var/log/named \
    && touch /var/log/named/named.log \
    && touch /var/log/named/security.log \
    && touch /var/log/named/queries.log \
    && chmod 777 /var/log/named/*

EXPOSE 53 53/udp

CMD ["/usr/sbin/named", "-c", "/etc/named.conf", "-u", "named", "-g"]
