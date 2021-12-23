# apache update helper
- do following command after execute apacheupdate.sh

```sh
# shutdown container
cd ~/docker \
&& sudo docker compose down

# remove old container image
sudo docker images
sudo docker rmi xxxxxxxxxxx

# edit apache/dockerfile
# apache バージョン更新
# nghttp2 のバージョンも更新がある場合は更新する

# build
sudo docker compose up -d
```
