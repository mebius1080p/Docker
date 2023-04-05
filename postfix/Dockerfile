# 自分自身へのメール送信のため、ホストの postfix にメールを転送するためだけのコンテナ

# イメージ作成
# sudo docker build -t postfix .
# sudo docker build -t postfix . --no-cache

FROM quay.io/centos/centos:stream9
LABEL maintainer="mebius"

RUN <<FIRST
echo "ip_resolve=4" >> /etc/yum.conf
yum update -y
yum install -y epel-release

yum install -y postfix supervisor

yum clean all
FIRST

COPY supervisord.conf /etc/

COPY postfix/main.cf /etc/postfix/

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
