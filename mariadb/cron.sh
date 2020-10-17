#!/bin/sh

LOG_FILE=~/cron.txt
DC_PATH_FILE=~/compose_dir.txt

# compose_dir.txt 存在チェック
if [ ! -e $DC_PATH_FILE ]; then
	echo `date +%Y-%m-%d_%H:%M:%S` compose_dir.txt not found >> $LOG_FILE
	exit 1;
fi

# ファイル内容のディレクトリチェック
dc_path=`cat $DC_PATH_FILE`
if [ ! -d $dc_path ]; then
	echo `date +%Y-%m-%d_%H:%M:%S` contents of compose_dir.txt is not dir path >> $LOG_FILE
	exit 1;
fi

# dump タスク
echo `date +%Y-%m-%d_%H:%M:%S` start dump >> $LOG_FILE

docker exec -it docker_mariadb_1 /var/share/dump.sh

echo `date +%Y-%m-%d_%H:%M:%S` end dump >> $LOG_FILE
