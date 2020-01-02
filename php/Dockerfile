# /var/log/php-fpm/error.log はエラーログ

# イメージ作成
# sudo docker build -t php .
# sudo docker build -t php . --no-cache

# メールは要確認

FROM centos:7
LABEL maintainer="mebius"

WORKDIR /root
ARG COMPOSER_VER=1.9.1

# git は composer の prestissimo プラグイン用
# openssl は php の暗号化の他、swiftmailer ダウンロードの際に必要
RUN yum update -y && yum install -y \
	epel-release \
	wget \
	openssl \
	&& wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm \
	&& rpm -Uvh remi-release-7.rpm \
	&& yum install -y --enablerepo=remi-php74 --enablerepo=epel \
	supervisor \
	php-fpm \
	php-cli \
	php-pdo \
	php-mysqlnd \
	php-mbstring \
	git \
	zip \
	unzip \
	&& yum clean all \
	&& mkdir -p /run/php-fpm \
	&& chmod 770 /run/php-fpm \
	&& wget https://getcomposer.org/download/${COMPOSER_VER}/composer.phar \
	&& wget https://getcomposer.org/download/${COMPOSER_VER}/composer.phar.sha256sum \
	&& sha256sum -c composer.phar.sha256sum \
	&& chmod 755 composer.phar \
	&& mv composer.phar /usr/bin/composer

# web ファイルの所有者を apache 側とそろえるため、ユーザー追加
ARG USER_NAME=workuser
RUN useradd ${USER_NAME}

# supervisor の設定
COPY supervisord.conf /etc/

# composer 用ルート証明書コピー
COPY curl.cacert.pem /etc/pki/tls/certs/

CMD ["/usr/bin/supervisord"]

# web のディレクトリは apache コンテナと合わせといた方が楽
# www.conf, php-fpm.conf は volume でホストと共有させる

# COPY php.ini したあとだめだったのになぜか docker run 後はうまくいく……
# composer global require hirak/prestissimo
