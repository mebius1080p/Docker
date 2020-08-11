# letsencrypt 用コンテナ readme

## cron
- ホストの root ユーザーに設定することを想定
- ログファイルは勝手に作られるが、compose_dir.txt だけはあらかじめ作成し、docker-compose プロジェクト設置パスのみをファイルに記述しておく
- 実行日時は月の初日など
```
# 例
32 03 01 * * /home/hoge/docker/letsencrypt/cron.sh
```
