# maria db container update memo

## update command
```sh
# ダンプ採取
# 開発も本番も同じはず
sudo docker exec -it docker-mariadb-1 bash
cd /var/share
mariadb-dump -u root -p food_review > food_review.dump
mariadb-dump -u root -p resume > resume.dump
mariadb-dump -u root -p sake > sake.dump
mariadb-dump -u root -p suna > suna.dump
exit

# ホストマシン
# cd ~/docker
cd ~/Docker
sudo docker compose down

# docker compose.yml 編集
# volume 変更
mysqldata121
# 本番の場合は下記
cd ~/Docker
git pull


#init_db.sql ファイルを share ディレクトリに置いておく


# イメージを最新に
sudo docker pull mariadb
sudo docker images

# バージョン確認
sudo docker run -itd --name mtest \
 -e TZ=Asia/Tokyo \
 -e MYSQL_ROOT_PASSWORD=root \
 mariadb bash

 # コンテナに入る
sudo docker exec -it mtest bash
mariadb -V
exit

# コンテナから出て、一時コンテナ破棄
sudo docker stop mtest \
&& sudo docker rm mtest


sudo docker compose up -d

sudo docker exec -it docker-mariadb-1 bash
cd /var/share
mariadb -u root -p
source init_db.sql

use food_review
source food_review.dump

use resume
source resume.dump

use sake
source sake.dump

use suna
source suna.dump

# ブラウザからアクセスして確認
```