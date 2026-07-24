# 障害対応記録 02：Nginx設定ファイルの構文エラー

## 1. 障害概要

| 項目 | 内容 |
|---|---|
| 対象サービス | Nginx |
| 障害種別 | 設定ファイルの構文エラー |
| 発生事象 | 設定変更後にReloadできない |
| 影響 | 新しい設定を反映できない |
| 対象ファイル | `/etc/nginx/sites-available/myapp.conf` |

## 2. 現象

Nginxの設定を変更した後、構文確認を実行するとエラーが表示された。

```bash
sudo nginx -t
```

```text
unexpected end of file, expecting "}"
nginx: configuration file /etc/nginx/nginx.conf test failed
```

### 発生時の画面

![Nginx syntax error](../screenshots/02_nginx_syntax_error.jpeg)

## 3. エラーの読み方

```text
unexpected end of file
```

設定ファイルを最後まで読んだが、必要な記述が不足していることを示す。

```text
expecting "}"
```

閉じ波括弧 `}` が不足していることを示す。

```text
/etc/nginx/sites-enabled/myapp.conf:21
```

エラーを検出したファイル名と行番号を示す。

## 4. 切り分け手順

### 4.1 構文を確認する

```bash
sudo nginx -t
```

### 4.2 行番号を表示して設定ファイルを確認する

```bash
sudo nl -ba /etc/nginx/sites-available/myapp.conf
```

以下を確認する。

- `server {` に対応する `}` があるか
- `location {` に対応する `}` があるか
- 各ディレクティブの末尾に `;` があるか

### 4.3 編集する

```bash
sudo vim /etc/nginx/sites-available/myapp.conf
```

## 5. 原因

設定変更時に閉じ波括弧 `}` を記述し忘れたため、Nginxが設定ファイルを正しく解析できなかった。

## 6. 対応

不足している `}` を追加する。

修正後、必ず構文確認を行う。

```bash
sudo nginx -t
```

正常な場合：

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

構文確認に成功した後、設定を再読み込みする。

```bash
sudo systemctl reload nginx
```

## 7. 復旧確認

```bash
sudo systemctl status nginx --no-pager
curl -I http://myapp.local
```

期待結果：

```text
HTTP/1.1 200 OK
```

> Reloadに失敗しても、既存のNginxプロセスが旧設定で動作を継続する場合がある。Webサイトが表示できるだけで判断せず、`nginx -t` とReload結果を確認する。

## 8. 再発防止

- 設定変更後は、Reload前に必ず `sudo nginx -t` を実行する。
- 大きな変更を一度に行わず、小さく変更して都度確認する。
- 変更前の設定ファイルをバックアップする。

```bash
sudo cp /etc/nginx/sites-available/myapp.conf \
  /etc/nginx/sites-available/myapp.conf.bak
```
