-- db バージョンアップ時など用初期化 sql サンプル

CREATE DATABASE hoge;

-- ユーザー作成
CREATE USER fuga IDENTIFIED BY 'xxxxxxxxxx';

-- 確認
SELECT Host, User, Password FROM mysql.user;


-- 権限付与
GRANT ALL ON hoge.* TO fuga;

-- 確認
SHOW GRANTS FOR fuga;