# 障害対応記録 01：ポート競合によりNginxを起動できない

## 1. 障害概要

| 項目 | 内容 |
|---|---|
| 対象サービス | Nginx |
| 障害種別 | ポート競合 |
| 発生事象 | Nginxの起動に失敗 |
| 影響 | Webサイトへアクセスできない |
| 使用ポート | TCP/80 |

## 2. 現象

Nginxを起動したところ、サービスの起動に失敗した。

```bash
sudo systemctl start nginx
```

```text
Job for nginx.service failed because the control process exited with error code.
```

### 発生時の画面

![Nginx start failed](../screenshots/01_port_conflict_start_failed.png)

## 3. 切り分け手順

### 3.1 Nginxの状態を確認する

```bash
sudo systemctl status nginx --no-pager
```

サービスが `failed` になっているか確認する。

### 3.2 詳細ログを確認する

```bash
sudo journalctl -xeu nginx.service
```

`Address already in use` や `bind() failed` が表示されている場合、ポート競合の可能性が高い。

### 3.3 ポート80を使用しているプロセスを確認する

```bash
sudo ss -lntp | grep ':80'
```

または：

```bash
sudo lsof -i :80
```

## 4. 原因

TCP/80番ポートを別のプロセスが使用していたため、Nginxがポート80を確保できず、起動に失敗した。

## 5. 対応

ポート80を使用しているサービスを確認し、不要なサービスを停止する。

例：Apacheが使用している場合

```bash
sudo systemctl stop apache2
```

その後、Nginxを起動する。

```bash
sudo systemctl start nginx
```

> 実運用では、プロセス名と影響範囲を確認してから停止する。原因確認なしで `kill -9` を使用しない。

## 6. 復旧確認

### 6.1 サービス状態

```bash
sudo systemctl is-active nginx
```

期待結果：

```text
active
```

### 6.2 ポート待受状態

```bash
sudo ss -lntp | grep ':80'
```

### 6.3 HTTP応答

```bash
curl -I http://myapp.local
```

期待結果：

```text
HTTP/1.1 200 OK
```

### 復旧後の画面

![HTTP 200 after recovery](../screenshots/01_port_conflict_recovered.png)

## 7. 再発防止

- 新しいWebサービスを起動する前に、使用予定ポートの待受状態を確認する。
- 同一サーバー上でNginxとApacheを併用する場合は、使用ポートを分ける。
- `systemctl status` と `journalctl` を利用し、起動失敗の原因をログから確認する。
