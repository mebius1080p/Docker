#!/bin/sh

LOG_FILE=~/cron.txt
DC_PATH_FILE=~/compose_dir.txt

# compose_dir.txt 存在チェック
if [ ! -e $DC_PATH_FILE ]; then
	echo "$(date +%Y-%m-%d_%H:%M:%S)" compose_dir.txt not found >> $LOG_FILE
	exit 1;
fi

# ファイル内容のディレクトリチェック
dc_path=$(cat $DC_PATH_FILE)
if [ ! -d "$dc_path" ]; then
	echo "$(date +%Y-%m-%d_%H:%M:%S)" contents of compose_dir.txt is not dir path >> $LOG_FILE
	exit 1;
fi

# certbot タスク
echo "$(date +%Y-%m-%d_%H:%M:%S)" start certbot >> $LOG_FILE

docker exec docker-letsencrypt-1 /root/scripts/renew.sh
# docker exec docker-letsencrypt-1 /root/scripts/renew.dev.sh

echo "$(date +%Y-%m-%d_%H:%M:%S)" end certbot >> $LOG_FILE


# docker compose 再起動タスク
echo "$(date +%Y-%m-%d_%H:%M:%S)" restarting container >> $LOG_FILE
cd "$dc_path" || exit
docker compose restart
echo "$(date +%Y-%m-%d_%H:%M:%S)" restarting container done >> $LOG_FILE
