# /var/log/php-fpm/error.log はエラーログ

# イメージ作成
# sudo docker build -t php .
# sudo docker build -t php . --no-cache

# メールは要確認

FROM centos:7
LABEL maintainer="mebius"

RUN yum update -y && yum install -y \
	epel-release \
	postfix \
	wget \
	&& wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm \
	&& rpm -Uvh remi-release-7.rpm \
	&& yum install -y --enablerepo=remi-php73 --enablerepo=epel \
	supervisor \
	php-fpm \
	php-cli \
	php-pdo \
	php-mysqlnd \
	php-mbstring \
	rsyslog \
	&& yum clean all \
	&& mkdir -p /run/php-fpm \
	&& chmod 770 /run/php-fpm

# web ファイルの所有者を apache 側とそろえるため、ユーザー追加
ARG USER_NAME=workuser
RUN useradd ${USER_NAME}

# このコンテナのメインである php 以外のコンポーネント conf についてはあらかじめコピーしてしまう
# コンテナでメールを受けるわけではないので master.cf はデフォルトのままでよい
COPY postfix/main.cf /etc/postfix/

# opendkim についてはホスト側で署名させるためコンテナでは設定しない

# alias の設定
COPY aliases /etc/
RUN /usr/bin/newaliases

# supervisor の設定
COPY supervisord.conf /etc/

# rsyslog の設定
COPY rsyslog/rsyslog.conf /etc/
COPY rsyslog/listen.conf /etc/rsyslog.d/

#EXPOSE 9000

CMD ["/usr/bin/supervisord"]

# web のディレクトリは apache コンテナと合わせといた方が楽
# www.conf, php-fpm.conf は volume でホストと共有させる
