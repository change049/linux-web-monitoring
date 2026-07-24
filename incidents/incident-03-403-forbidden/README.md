# 障害対応記録 03：403 Forbidden（ディレクトリ権限不足）

## 1. 障害概要

| 項目 | 内容 |
|---|---|
| 対象サービス | Nginx |
| 障害種別 | Linuxファイル権限 |
| 発生事象 | Webページへのアクセス時に403を返す |
| 影響 | コンテンツを表示できない |
| 対象ディレクトリ | `/var/www/myapp` |

## 2. 現象

Webサイトへアクセスすると、`403 Forbidden` が返された。

```bash
curl -I http://myapp.local
```

```text
HTTP/1.1 403 Forbidden
```

### 発生時の画面

![403 Forbidden after chmod 700](../screenshots/03_403_forbidden.jpeg)

## 3. 切り分け手順

### 3.1 Nginxエラーログを確認する

```bash
sudo tail -20 /var/log/nginx/myapp_error.log
```

確認したメッセージ：

```text
/var/www/myapp/index.html is forbidden
(13: Permission denied)
```

`Permission denied` は、Linuxの権限によってアクセスを拒否されたことを示す。

### 3.2 パス全体の権限を確認する

```bash
namei -l /var/www/myapp/index.html
```

`namei -l` は、次の各階層を順番に確認する。

```text
/
└── var
    └── www
        └── myapp
            └── index.html
```

### ログおよび権限確認の画面

![Permission denied and namei output](../screenshots/03_permission_denied_log.png)

## 4. 原因

次のコマンドで、`/var/www/myapp` の権限を `700` に変更していた。

```bash
sudo chmod 700 /var/www/myapp
```

`700` の意味：

| 対象 | 権限 |
|---|---|
| 所有者（root） | 読み取り・書き込み・実行可能 |
| グループ | 権限なし |
| その他 | 権限なし |

Nginxのワーカープロセスは通常 `www-data` ユーザーで動作する。`www-data` はディレクトリ内へ移動できないため、`index.html` を読み取れず403となった。

## 5. 対応

ディレクトリ権限を `755` に戻す。

```bash
sudo chmod 755 /var/www/myapp
```

確認する。

```bash
ls -ld /var/www/myapp
```

期待結果：

```text
drwxr-xr-x ... /var/www/myapp
```

> 今回の原因は所有者ではなく、ディレクトリの権限 `700` である。`root:root` の所有でも、ディレクトリが755、HTMLファイルが644であれば、通常Nginxは読み取り可能である。

## 6. 復旧確認

```bash
curl -I http://myapp.local
```

期待結果：

```text
HTTP/1.1 200 OK
```

必要に応じてログも確認する。

```bash
sudo tail -20 /var/log/nginx/myapp_error.log
```

新しい `Permission denied` が出ていないことを確認する。

## 7. 再発防止

- `chmod` 実行前に現在の権限を記録する。
- Web公開ディレクトリの権限を一括変更するときは影響範囲を確認する。
- 403発生時は、Nginx設定だけでなくLinuxの権限とエラーログを確認する。
