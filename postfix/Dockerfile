# 自分自身へのメール送信のため、ホストの postfix にメールを転送するためだけのコンテナ

# イメージ作成
# sudo docker build -t postfix .
# sudo docker build -t postfix . --no-cache

FROM centos:7
LABEL maintainer="mebius"

RUN echo "ip_resolve=4" >> /etc/yum.conf \
	&& yum update -y \
	&& yum install -y \
	epel-release \
	&& yum install -y \
	postfix \
	supervisor \
	rsyslog \
	&& yum clean all

COPY supervisord.conf /etc/

COPY postfix/main.cf /etc/postfix/

COPY rsyslog/rsyslog.conf /etc/
COPY rsyslog/listen.conf /etc/rsyslog.d/

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
