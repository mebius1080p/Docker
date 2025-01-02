# php container update
- 開発環境で実施
```sh
# 空の centos コンテナ起動
sudo docker run -itd --name ptest \
 -e TZ=Asia/Tokyo \
 quay.io/centos/centos:stream9 bash

# コンテナに入る
sudo docker exec -it ptest bash

# php インストール
echo "ip_resolve=4" >> /etc/yum.conf
yum install epel-release wget
wget -4 https://rpms.remirepo.net/enterprise/remi-release-9.rpm \
&& rpm -Uvh remi-release-9.rpm

dnf module enable php:remi-8.4 -y
dnf install php-fpm php-cli php-pdo php-mysqlnd php-mbstring php-xml -y

# ファイル取りだし
# ホストマシンで実行
cd ~/Docker/misc
sudo docker cp ptest:/etc/php-fpm.d/www.conf ./
sudo docker cp ptest:/etc/php.ini ./

# コンテナから出て、一時コンテナ破棄
sudo docker stop ptest \
&& sudo docker rm ptest


# コンテナ停止
cd ~/Docker
sudo docker compose down

# ここで php.ini, www.conf を比較しながら編集
cd ~/Docker/misc
sudo chown xxx:xxx php.ini
sudo chown xxx:xxx www.conf

# ファイル更新(上書き)
cd ~/Docker/php/conf
cp ~/Docker/misc/php.ini ./
cp ~/Docker/misc/www.conf ./

# コンテナイメージ削除
sudo docker rmi docker-php

sudo docker pull quay.io/centos/centos:stream9

# dockerfile 更新

# コンテナ起動
cd ~/Docker
sudo docker compose up -d

# 開発用コンポーネントインストール
sudo docker exec -it docker-php-1 bash
yum install php-ast php-pecl-xdebug3
su - workuser

composer global require phan/phan

vi .bashrc
# $HOME/.config/composer/vendor/bin
source .bashrc

vi .bashrc
# alias phan='phan --progress-bar --color'
source .bashrc

# 動作チェックする

# おまけ
# 各種プロジェクトで phan config 更新
# 既存の config.php を名前変更
phan --init --init-level=1
```

## イメージの転送
```sh
sudo docker save docker-php > docker-php.tar

# ファイルを転送する

# イメージのロード
cd ~/Docker
sudo docker compose down
sudo docker rmi docker-php
sudo docker images
cd xxx
sudo docker load < docker-php.tar

cd ~/Docker
sudo docker compose up -d
```

## on production
```sh
cd ~/Docker
sudo docker compose down

git pull
sudo docker rmi docker_php

sudo docker compose up -d

# 確認
sudo docker ps -a
```