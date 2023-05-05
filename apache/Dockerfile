# イメージ作成
# sudo docker build -t apache .
# sudo docker build -t apache . --no-cache

FROM quay.io/centos/centos:stream9
LABEL maintainer="mebius"

RUN echo "ip_resolve=4" >> /etc/yum.conf \
	&& yum update -y \
	&& yum install epel-release -y \
	&& yum install httpd mod_ssl mod_http2 supervisor -y \
	&& yum clean all \
	&& mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.orig \
	&& mkdir -p /var/run/php-fpm \
	&& chmod 777 /var/run/php-fpm

# どのイメージでも共通の conf ファイルのコピー
COPY conf.d/deflate.conf /etc/httpd/conf.d/deflate.conf
COPY conf.d/expire.conf /etc/httpd/conf.d/expire.conf

# supervisor の設定
COPY supervisord.conf /etc

# EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
