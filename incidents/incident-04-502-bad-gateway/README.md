# 障害対応記録 04：502 Bad Gateway（PHP-FPM停止）

## 1. 障害概要

| 項目 | 内容 |
|---|---|
| 対象サービス | Nginx / PHP-FPM 8.5 |
| 障害種別 | バックエンドサービス停止 |
| 発生事象 | PHPページへのアクセス時に502を返す |
| 影響 | PHPコンテンツを表示できない |
| 対象URL | `http://myapp.local/index.php` |

## 2. システム構成

Nginx自身はPHPを実行できないため、PHPリクエストをPHP-FPMへ渡す。

```text
クライアント
    ↓ HTTP
Nginx
    ↓ FastCGI / Unix Socket
PHP-FPM
```

## 3. 現象

PHP-FPMを停止した状態でPHPページへアクセスすると、`502 Bad Gateway` が返された。

```bash
curl -I http://myapp.local/index.php
```

```text
HTTP/1.1 502 Bad Gateway
```

### 発生時の画面

![502 Bad Gateway](../screenshots/04_502_bad_gateway.png)

## 4. 切り分け手順

### 4.1 PHP-FPMの状態を確認する

```bash
sudo systemctl status php8.5-fpm --no-pager
```

停止している場合：

```text
Active: inactive (dead)
```

### 4.2 Nginxエラーログを確認する

```bash
sudo tail -20 /var/log/nginx/myapp_error.log
```

想定されるメッセージ：

```text
connect() to unix:/run/php/php8.5-fpm.sock failed
```

### 4.3 実際のSocketファイルを確認する

```bash
ls -l /run/php/
```

PHP-FPM起動時に、次のSocketが存在するか確認する。

```text
php8.5-fpm.sock
```

### 4.4 Nginxの接続先を確認する

```bash
grep fastcgi_pass /etc/nginx/sites-available/myapp.conf
```

期待する設定：

```nginx
fastcgi_pass unix:/run/php/php8.5-fpm.sock;
```

実際のSocketパスとNginx設定のパスが一致している必要がある。

## 5. 原因

PHP-FPMサービスが停止していたため、NginxがPHPの処理を依頼する接続先へ到達できず、502 Bad Gatewayを返した。

## 6. 対応

PHP-FPMを起動する。

```bash
sudo systemctl start php8.5-fpm
```

自動起動設定も確認する。

```bash
sudo systemctl enable php8.5-fpm
```

Nginx設定を変更した場合は、構文確認後にReloadする。

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 7. 復旧確認

### 7.1 PHP-FPMの状態

```bash
sudo systemctl is-active php8.5-fpm
```

期待結果：

```text
active
```

### 7.2 PHPページの応答

```bash
curl http://myapp.local/index.php
```

PHPの実行結果が返ることを確認する。

HTTPステータスだけを確認する場合：

```bash
curl -I http://myapp.local/index.php
```

期待結果：

```text
HTTP/1.1 200 OK
```

## 8. 再発防止

- PHP-FPMをZabbixなどでサービス監視する。
- PHP-FPM停止時にアラートを通知する。
- PHP更新後は、NginxのSocketパスがPHPのバージョンと一致しているか確認する。
- 502発生時は、Nginxだけでなくバックエンドサービスの状態も確認する。
