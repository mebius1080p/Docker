#!/bin/sh

LOG_FILE=~/cron.txt

echo `date +%Y-%m-%d_%H:%M:%S` start certbot >> $LOG_FILE

# docker exec -it docker_letsencrypt_1 /root/scripts/certonly.sh
docker exec -it docker_letsencrypt_1 /root/scripts/certonly.dev.sh

echo `date +%Y-%m-%d_%H:%M:%S` end certbot >> $LOG_FILE
