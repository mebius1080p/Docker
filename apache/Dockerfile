# イメージ作成
# sudo docker build -t apache .
# sudo docker build -t apache . --no-cache


# apr の rpm 作成でエラーが出るため、IPv6 を有効化しておく
# image 作成後は元に戻してもいいかも
# /etc/docker/daemon.json を作成 下記を記述
# {
#   "ipv6": true,
#   "fixed-cidr-v6": "2001:db8:1::/64"
# }

FROM centos:7
LABEL maintainer="mebius"

# パッケージの更新とインストール
# 更新とパッケージのインストールは一緒に行って効率化

# python-devel と file は nghttp2 用
# which, libuuid-devel は APR の rpm 作成中に使用してるみたいなので入れる
# mailcap, lua-devel, libxml2-devel は apache に必要とされるらしい

# apr-util を自前で作成する場合(1.6.x)、下記が必要となるようだが、
# yum にあるものはバージョンが上がっているのでそちらを利用した方がよい
# libuuid-devel, expat-devel, libdb-devel
# openssl-devel, postgresql-devel, sqlite-devel, unixODBC-devel, openldap-devel, nss-devel

# distcache の rpm 作成で、
# openssl-devel, initscripts(/sbin/service) が必要

# docker build 時に yum で ipv4 のみ使用させるよう、真っ先に設定しておく

RUN echo "ip_resolve=4" >> /etc/yum.conf \
	&& yum update -y \
	&& yum install epel-release -y \
	&& yum install -y --enablerepo=epel \
	perl \
	make \
	gcc \
	wget \
	python-devel \
	file \
	rpm-build \
	autoconf \
	libtool \
	doxygen \
	sudo \
	which \
	libuuid-devel \
	mailcap \
	lua-devel \
	libxml2-devel \
	openssl-devel \
	initscripts \
	supervisor \
	&& yum clean all \
	&& mkdir -p /var/run/php-fpm \
	&& chmod 777 /var/run/php-fpm


# rpmbuild のため、ユーザーの追加を行う
ARG USER_NAME=workuser
RUN useradd ${USER_NAME} \
	&& usermod -aG wheel ${USER_NAME} \
	&& sed -i -e 's/# %wheel\tALL=(ALL)\tNOPASSWD: ALL/%wheel\tALL=(ALL)\tNOPASSWD: ALL/' /etc/sudoers \
	&& sed -i -e 's/%wheel\tALL=(ALL)\tALL/# %wheel\tALL=(ALL)\tALL/' /etc/sudoers \
	&& visudo -c


# distcache のインストール
# openssl 更新前に作って入れてしまう
# 古いけど……
USER ${USER_NAME}
# WORKDIR /home/${USER_NAME}/download
# WORKDIR でディレクトリを作らせると所有者が root になってしまうようなので、最初は手動で作成する
RUN mkdir ~/download -p \
	&& cd ~/download \
	&& wget -4 https://archive.fedoraproject.org/pub/archive/fedora/linux/releases/18/Everything/source/SRPMS/d/distcache-1.4.5-23.src.rpm \
	&& rpmbuild --rebuild --clean distcache-1.4.5-23.src.rpm \
	&& cd ~/rpmbuild/RPMS/x86_64 \
	&& sudo rpm -Uvh distcache-1.4.5-23.x86_64.rpm distcache-devel-1.4.5-23.x86_64.rpm \
	&& rm ~/download/distcache-1.4.5-23.src.rpm


# openssl 更新
# ADD などを使うと 1 layer 使ってしまうので、curl, wget を使う方がいいらしい
# openssl version コマンドを実行すると libssl.so.1.1 が見つからなくてエラーとなる
# RUN find / -name libssl.so.1.1
# => /usr/local/lib64/libssl.so.1.1
# 最後に ldconfig コマンドでライブラリの場所を指定する
WORKDIR /home/${USER_NAME}/download
ARG OPENSSL_VERSION=1.1.1h
RUN wget -4 https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
	&& tar xvf openssl-${OPENSSL_VERSION}.tar.gz \
	&& cd openssl-${OPENSSL_VERSION} \
	&& ./config \
	&& make \
	&& sudo make install \
	&& echo /usr/local/lib64/ > lib64.conf \
	&& sudo cp lib64.conf /etc/ld.so.conf.d/lib64.conf \
	&& sudo ldconfig \
	&& rm ~/download/openssl-${OPENSSL_VERSION}.tar.gz \
	&& rm -rf ~/download/openssl-${OPENSSL_VERSION}


# nghttp2 インストール
# /usr/local/lib に入る
WORKDIR /home/${USER_NAME}/download
ARG NGHTTP2_VERSION=1.41.0
RUN wget -4 https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.xz \
	&& tar xvf nghttp2-${NGHTTP2_VERSION}.tar.xz \
	&& cd nghttp2-${NGHTTP2_VERSION} \
	&& export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig \
	&& ./configure \
	&& make \
	&& sudo make install \
	&& echo /usr/local/lib > lib.conf \
	&& sudo cp lib.conf /etc/ld.so.conf.d/lib.conf \
	&& sudo ldconfig \
	&& rm ~/download/nghttp2-${NGHTTP2_VERSION}.tar.xz \
	&& rm -rf ~/download/nghttp2-${NGHTTP2_VERSION}


# APR, APR-UTIL のインストール
# APR-UTIL は新しいものが yum にあるのでそれを使う
WORKDIR /home/${USER_NAME}/download
ARG APR_VERSION=1.7.0
RUN wget -4 http://ftp.jaist.ac.jp/pub/apache//apr/apr-${APR_VERSION}.tar.bz2 \
	&& rpmbuild -tb --clean apr-${APR_VERSION}.tar.bz2 \
	&& cd ~/rpmbuild/RPMS/x86_64 \
	&& sudo rpm -Uvh apr-${APR_VERSION}-1.x86_64.rpm apr-devel-${APR_VERSION}-1.x86_64.rpm \
	&& sudo yum install apr-util-devel -y \
	&& yum clean all \
	&& rm ~/download/apr-${APR_VERSION}.tar.bz2 \
	&& rm -rf ~/download/apr-${APR_VERSION}


# apache のインストール
# httpd.spec ファイルはあらかじめ編集しておく
WORKDIR /home/${USER_NAME}/download
ARG APACHE_VERSION=2.4.46
COPY spec/httpd.spec /home/${USER_NAME}/rpmbuild/SPECS/
RUN wget -4 https://www-eu.apache.org/dist//httpd/httpd-${APACHE_VERSION}.tar.bz2 \
	&& cp httpd-${APACHE_VERSION}.tar.bz2 ~/rpmbuild/SOURCES \
	&& cd ~/rpmbuild/SPECS \
	&& export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig \
	&& rpmbuild -bb --clean httpd.spec \
	&& cd ~/rpmbuild/RPMS/x86_64 \
	&& sudo rpm -Uvh --force --nodeps httpd-${APACHE_VERSION}-1.x86_64.rpm httpd-devel-${APACHE_VERSION}-1.x86_64.rpm mod_ssl-${APACHE_VERSION}-1.x86_64.rpm \
	&& rm ~/download/httpd-${APACHE_VERSION}.tar.bz2 \
	&& rm ~/rpmbuild/SOURCES/httpd-${APACHE_VERSION}.tar.bz2

USER root

# どのイメージでも共通の conf ファイルのコピー
COPY conf.d/deflate.conf /etc/httpd/conf.d/deflate.conf
COPY conf.d/expire.conf /etc/httpd/conf.d/expire.conf

# supervisor の設定
COPY supervisord.conf /etc

# 起動スクリプトの設置
COPY _init_.sh /_init_.sh

EXPOSE 80 443

CMD ["sh", "/_init_.sh"]
