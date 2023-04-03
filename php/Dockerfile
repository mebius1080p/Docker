# /var/log/php-fpm/error.log はエラーログ

# イメージ作成
# sudo docker build -t php .
# sudo docker build -t php . --no-cache

FROM quay.io/centos/centos:stream9
LABEL maintainer="mebius"

WORKDIR /root
ARG COMPOSER_VER=2.5.5

# git は composer モジュールインストール用?
# openssl は php の暗号化の他、swiftmailer ダウンロードの際に必要
# curl は既に入っているようなので devel のみ入れる
RUN <<FIRST
echo "ip_resolve=4" >> /etc/yum.conf
yum update -y
yum install epel-release wget -y
yum install git zip unzip curl-devel tzdata openssl supervisor -y

wget -4 https://rpms.remirepo.net/enterprise/remi-release-9.rpm
rpm -Uvh remi-release-9.rpm

dnf module enable php:remi-8.2 -y
dnf install php-fpm php-cli php-pdo php-mysqlnd php-mbstring php-xml -y
yum clean all

mkdir -p /run/php-fpm
chmod 777 /run/php-fpm

wget -4 https://getcomposer.org/download/${COMPOSER_VER}/composer.phar
wget -4 https://getcomposer.org/download/${COMPOSER_VER}/composer.phar.sha256sum
sha256sum -c composer.phar.sha256sum
chmod 755 composer.phar
mv composer.phar /usr/bin/composer
FIRST

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
