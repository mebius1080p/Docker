# HTTP2, TLS 1.3 を使えるサイトに必要なコンテナを作るための Docker リポジトリ

## 概要
- apache, php, postfix は centos stream ベースのイメージから構築
- MariaDB は公式イメージを使用
- それぞれ個別のコンテナで動かす
- 接続
	* apache <=PHP-FPM(socket)=> PHP <=socket=> MariaDB
	* PHP <=docker network=> postfix
- apache, php, postfix では supervisor を使用する
- supervisor
	* https://techracho.bpsinc.jp/morimorihoge/2017_06_05/40936
	* https://techracho.bpsinc.jp/hachi8833/2018_09_04/61176
	* http://docs.docker.jp/engine/articles/using_supervisord.html
- ソケットファイル共有での参考サイト
	* https://oki2a24.com/2018/07/29/useing-unix-domain-socket-to-nginx-php-fpm-in-docker/
	* https://christina04.hatenablog.com/entry/2016/05/04/134323
- メールは、一旦別コンテナの postfix を経由後、さらにホストの postfix を経由して dkim 署名の後送信する構成とする
	* これは ipv6 対応のために php コンテナを host ネットワークに接続したとき、ホスト側の postfix にリレーできなかったから
		- spf などの都合上、メール送信サーバーのアドレスはホストのアドレスとしたい
		- php コンテナ内から内部の postfix を使用して docker0(172.17.0.1 など) にリレーさせると自分へのリレーと認識される
		- メールサーバーをホストでも実行する場合、自身に対してはメールが送れなかった。
	* opendkim の署名はホストで行う
	* php からのメール送信は、swiftmailer, phpmailer 等のライブラリを使用する
- ipv6 対応のため、apache, php は host ネットワークに接続する
	* php 側でも ipv6 の機能を使うことがあるかもしれないので
	* docker の ipv6 に関してはまだベストプラクティスがないらしいので host に接続
	* vps で複数のアドレスが持てなそうなこと、ipv6 ルーティング設定が面倒なことも理由
		- unique local address ...
	* postfix, mariadb は bridge に接続
	* ホストの /etc/docker/daemon.json は設置したままにする
		```json
		{
		  "ipv6": true,
		  "fixed-cidr-v6": "2001:db8:1::/64"
		}
		```


## Apache
### about httpd config
- /etc/httpd/conf
	* httpd.conf
		- deflate, proxy, mod_proxy_fcgi, ssl, mod_http2, mod_rewrite, mod_socache_shmcb の有効化
		- ServerTokens Prod
		- Include /etc/httpd/conf.d/*.conf
		- Include /path/to/vhost.conf

### vhost.conf
- php-fpm との連携での最重要設定
```conf
<FilesMatch ".*\.php$">
    SetHandler "proxy:unix:/var/run/php-fpm/php8.sock|fcgi://localhost"
</FilesMatch>
```

### ホストとのファイル共有
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
listen = /var/run/php-fpm/php8.sock

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

### DSN
- mysql:unix_socket=/var/lib/mysql/mysql.sock;dbname=hogedb;charset=utf8



## misc

### composer
- composer 自体は dockerfile に組み込み


### 開発環境限定 (php コンテナ)
- docker run した後コンテナ内で下記をインストール
	```sh
	# root
	yum install php-pecl-xdebug php-ast php-xml

	# phpunit はプロジェクトごとのインストールを推奨
	# cd
	# wget https://phar.phpunit.de/phpunit-9.phar
	# mv phpunit-9.phar phpunit
	# chmod 755 phpunit
	# mv phpunit /usr/bin/

	# workuser で実施
	composer global require phan/phan
	cd
	vi .bashrc

	alias phan='~/.composer/vendor/bin/phan --progress-bar --color'
	# alias phpunit='phpunit --color'
	# exit して workuser にスイッチ
	```


## Docker network
- 必要なくなったが参考までに残しておく
- sudo docker network create xxxxxxxx
	```
	docker network create --ipv6 --subnet=172.18.0.0/16,xxxx:xxxx:xxxx:xxxx::/64 --gateway=172.18.0.1 lamp
	```
- sudo docker network ls
- docker run のときに、--network xxxxxxxx オプションを指定する
- //php で使用する config などで、mysql/mariadb の dsn に注意


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
