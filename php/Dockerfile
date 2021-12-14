# /var/log/php-fpm/error.log はエラーログ

# イメージ作成
# sudo docker build -t php .
# sudo docker build -t php . --no-cache

# メールは要確認

FROM centos:7
LABEL maintainer="mebius"

WORKDIR /root
ARG COMPOSER_VER=2.1.14

# git は composer モジュールインストール用?
# openssl は php の暗号化の他、swiftmailer ダウンロードの際に必要
RUN echo "ip_resolve=4" >> /etc/yum.conf \
	&& yum update -y \
	&& yum install -y \
	epel-release \
	wget \
	openssl \
	&& wget -4 https://rpms.remirepo.net/enterprise/remi-release-7.rpm \
	&& rpm -Uvh remi-release-7.rpm \
	&& yum install -y --enablerepo=remi-php81 \
	supervisor \
	php-fpm \
	php-cli \
	php-pdo \
	php-mysqlnd \
	php-mbstring \
	php-xml \
	git \
	zip \
	unzip \
	&& yum clean all \
	&& mkdir -p /run/php-fpm \
	&& chmod 770 /run/php-fpm \
	&& wget -4 https://getcomposer.org/download/${COMPOSER_VER}/composer.phar \
	&& wget -4 https://getcomposer.org/download/${COMPOSER_VER}/composer.phar.sha256sum \
	&& sha256sum -c composer.phar.sha256sum \
	&& chmod 755 composer.phar \
	&& mv composer.phar /usr/bin/composer

# web ファイルの所有者を apache 側とそろえるため、ユーザー追加
ARG USER_NAME=workuser
RUN useradd ${USER_NAME}

# supervisor の設定
COPY supervisord.conf /etc/

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# web のディレクトリは apache コンテナと合わせといた方が楽
# www.conf, php-fpm.conf は volume でバインド

# 以下開発環境
# yum install --enablerepo=remi-php81 php-ast php-pecl-xdebug3

# workuser で実施
# su - workuser
# composer global require phan/phan

# .bash_profile
# path ~/.config/composer/vendor/bin

# .bashrc
# alias phan='phan --progress-bar --color'
