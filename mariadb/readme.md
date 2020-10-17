# readme
## cron
- ホストの root ユーザーに設定することを想定
- ログファイルは勝手に作られるが、compose_dir.txt だけはあらかじめ作成し、docker-compose プロジェクト設置パスのみをファイルに記述しておく
- 実行日時は月の初日など
```sh
# 例
01 02 * * * /home/hoge/docker/mariadb/cron.sh
```
- コンテナ内で実行する scripts/dump.sh は、あらかじめ share ディレクトリにコピーしておく
- xxxxxxxx ファイルも同様にコピーしておく