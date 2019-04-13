# TLS 1.3 を使える最新環境のコンテナを作るための Docker リポジトリ

## 概要
- apache, php は centos7 ベースのイメージから構築
- MariaDB は公式イメージを使用
- それぞれ個別のコンテナを動かす
- dockernetwork を一部使用
	* apache <=PHP-FPM(socket)=> PHP <=socket=> MariaDB
	* ネットワーク名は lamp とか適当に……
- apache, php では supervisor を使用する
- supervisor
	* https://techracho.bpsinc.jp/morimorihoge/2017_06_05/40936
	* https://techracho.bpsinc.jp/hachi8833/2018_09_04/61176
	* http://docs.docker.jp/engine/articles/using_supervisord.html
- ソケットファイル共有での参考サイト
	* https://oki2a24.com/2018/07/29/useing-unix-domain-socket-to-nginx-php-fpm-in-docker/
	* https://christina04.hatenablog.com/entry/2016/05/04/134323
- メールは、ホストの postfix を経由して dkim 署名の後送信する構成とする
	* opendkim の署名はホストで行う


## Apache
### about httpd config
- /etc/httpd/conf
	* httpd.conf
		- deflate, proxy, mod_proxy_fcgi, ssl, mod_http2, mod_rewrite, mod_socache_shmcb の有効化
		- ServerTokens Prod
		- Include /etc/httpd/conf.d/*.conf
		- Include /path/to/vhost.conf
		- 開発用コンテナでは二種類の conf を読む構成とする
			* 二つのサイトの開発を行う

### vhost.conf
- php-fpm との連携での最重要設定
```conf
# 最終的に下記で動作させた
# docker network 経由での通信はうまくいかなかったが、こちらの方が速いらしいのでこれでよし
<FilesMatch ".*\.php$">
    SetHandler "proxy:unix:/var/run/php-fpm/php7.sock|fcgi://localhost"
</FilesMatch>
```

### ホストとのファイル共有
- web files の設置……
	* コンテナ内のパスは /var/www/xxxx を想定
	* ディレクトリそのものを共有
	* 読み書き
	* マウントディレクトリは下記の通り
		- 開発環境では webx (webm|webg)
		- 本番では web
- 証明書
	* 個別のファイルを共有
	* 読み取りのみ
	* /etc/pki/tls/certs
		- server.cert
		- server.int.cert
		- server.key
		- permission 600
		- owner root
- apache 自体のログなど
	* /var/log/httpd
	* ディレクトリそのものを共有
	* permission 644 ?
	* owner root
	* 読み書き
- ソケットファイル
	* -v phpsock:/var/run/php-fpm で共有
		- phpsock はわかりやすい名前でよい
		- /var/run を共有すると supervisor の pid ファイルがかぶってしまうのでサブディレクトリを共有



## PHP
### about php.ini
- 最重要 php.ini 設定
	* date.timezone = Asia/Tokyo
	* pdo_mysql.default_socket=/var/lib/mysql/mysql.sock

### www.conf
- 重要設定
```conf
listen = /var/run/php-fpm/php7.sock

listen.owner = daemon
listen.group = daemon
```
- 便利と思われる設定
```
catch_workers_output = yes
```
- エラーに関して
	* ログには soap.wsdl_cache_dir のエラーが出るが、使わないので放置

### php-fpm.conf
- デフォルトのままで OK

### ホストとのファイル共有
- web ファイル
	* apache コンテナと同じパスに共有させる
- ログディレクトリ
- php-fpm.conf
	* 読み取り専用
- www.conf
	* 読み取り専用
- php.ini
	* 読み取り専用
- ソケットファイル
	* -v phpsock:/var/run/php-fpm で共有

### DSN
- mysql:unix_socket=/var/lib/mysql/mysql.sock;dbname=hogedb;charset=utf8



## misc

### 起動順
- php コンテナの方を先に起動し、ソケットファイルを作成させる

### composer どうするのか問題
- docker run した後 php コンテナ内でセットアップ
	* プラグインインストール
		```
		# cp /home/workuser/download/composer.phar /usr/bin/composer

		$ composer global require hirak/prestissimo
		## git が必要なので注意……
		```
- 公式イメージを使用する場合……
	* https://hub.docker.com/_/composer


### メモリ使用量
- sudo docker stats
	* mariadb	95MB
	* apache	21MB
	* php		26MB

### イメージサイズ
- 352+368+638 = 1358
- centos のイメージ 202


## Docker network
- sudo docker network create xxxxxxxx
	```
	docker network create --ipv6 --subnet=172.18.0.0/16,xxxx:xxxx:xxxx:xxxx::/64 --gateway=172.18.0.1 lamp
	```
- sudo docker network ls
- docker run のときに、--network xxxxxxxx オプションを指定する
- php で使用する config などで、mysql/mariadb の dsn に注意


## ローカルの開発環境用オレオレ証明書作成手順
```
openssl genrsa 2048 > hoge.net.key
openssl req -new -key hoge.net.key > hoge.net.csr
JP
TOKYO
x_city
...
hoge.net

openssl x509 -in hoge.net.csr -days 36500 -req -signkey hoge.net.key > server.crt
```

## 課題
- docker compose 化
- composer 問題