# maria db container update memo

## update command
```sh
# ダンプ採取
# 開発も本番も同じはず
sudo docker exec -it docker-mariadb-1 bash
cd /var/share
mysqldump -u root -p food_review > food_review.dump
mysqldump -u root -p resume > resume.dump
mysqldump -u root -p sake > sake.dump
mysqldump -u root -p suna > suna.dump
exit

cd ~/docker
#cd ~/Docker
sudo docker compose down

# docker compose.yml 編集
# volume 変更
mysqldata112
# 本番の場合は下記
cd ~/Docker
git pull


#init_db.sql ファイルを share ディレクトリに置いておく


# イメージを最新に
sudo docker pull mariadb

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