#!/bin/sh

cd /var/share

mysqldump --defaults-extra-file=mariadb.ini food_review > `date +%Y-%m-%d_%H:%M:%S`.food_review.dump
mysqldump --defaults-extra-file=mariadb.ini sake > `date +%Y-%m-%d_%H:%M:%S`.sake.dump
mysqldump --defaults-extra-file=mariadb.ini suna > `date +%Y-%m-%d_%H:%M:%S`.suna.dump
mysqldump --defaults-extra-file=mariadb.ini resume > `date +%Y-%m-%d_%H:%M:%S`.resume.dump

# 古いダンプの削除
find ./*.dump -mtime +30 -exec rm -f {} \;
