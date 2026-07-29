# Linux Web Server 運用監視プロジェクト

## 概要

Ubuntu上にNginx Webサーバーを構築し、Shell Script、cron、Zabbixを利用した運用監視環境を構築しました。

Linuxインフラ運用業務を想定し、サーバー監視、自動化、バックアップ、デプロイ、障害対応、アラート通知までの一連の運用を実践しています。

---

## 主な機能

- Nginx Webサーバー構築
- ヘルスチェック自動化
- アクセスログ分析
- バックアップ自動化
- サービス自動復旧
- デプロイ自動化
- cronによる定期実行
- Zabbixによるサーバー監視
- Trigger Actionによるメール通知
- SSL証明書の有効期限監視
- 障害シミュレーションおよび復旧確認

---

## システム構成

```text
Ubuntu Server
    ├── Nginx
    ├── Shell Scripts
    ├── cron
    └── Zabbix Agent 2
            ↓
      Zabbix Server
            ↓
    Trigger / Email Alert
```

---

## 実装内容

- [x] Nginxインストール
- [x] カスタムServer Block作成
- [x] Webページ作成
- [x] HTTP・HTTPS動作確認
- [x] UFW設定
- [x] ヘルスチェックスクリプト
- [x] アクセスログ分析スクリプト
- [x] バックアップスクリプト
- [x] サービス自動復旧スクリプト
- [x] デプロイスクリプト
- [x] cronによる定期実行
- [x] Zabbix Agent 2導入
- [x] Nginxサービス監視
- [x] Nginx接続数監視
- [x] ディスク使用率監視
- [x] SSL証明書有効期限監視
- [x] メールアラート設定
- [x] 障害シミュレーション
- [x] 障害対応手順書作成

---

## ディレクトリ構成

```text
linux-web-monitoring/
├── configs/
│   ├── docker/
│   ├── nginx/
│   └── zabbix-agent2/
├── cron/
├── docs/
│   └── zabbix/
├── incidents/
├── scripts/
│   ├── health_check.sh
│   ├── log_analysis.sh
│   ├── backup.sh
│   ├── auto_recover.sh
│   ├── deploy.sh
│   ├── check_nginx.sh
│   ├── check_nginx_active.sh
│   └── setup_cron.sh
├── screenshots/
├── web/
└── README.md
```

---

## 使用技術

- Ubuntu
- Nginx
- Bash
- cron
- systemd
- UFW
- Docker
- Zabbix Server
- Zabbix Agent 2
- OpenSSL
- VMware Fusion

---

## Zabbix監視項目

- Nginxサービス稼働状態
- Nginx Active Connections
- Linuxファイルシステム使用率
- SSL証明書の有効期限
- SSL証明書の検証結果
- 証明書フィンガープリント変更
- Trigger Actionによる障害・復旧メール通知

---

## Incident Simulation

1. [Port Conflict](incidents/incident-01-port-conflict/)
2. [Nginx Syntax Error](incidents/incident-02-nginx-syntax-error/)
3. [403 Forbidden](incidents/incident-03-403-forbidden/)
4. [502 Bad Gateway](incidents/incident-04-502-bad-gateway/)
5. [504 Gateway Timeout](incidents/incident-05-504-gateway-timeout/)
6. [Disk Full](incidents/incident-06-disk-full/)
7. [Zabbix Disk Space Monitoring](incidents/incident-07-zabbix-disk-monitoring/)
8. [Zabbix SSL Certificate Monitoring](incidents/incident-08-ssl-certificate-monitoring/)

---

## プロジェクトで実践した運用フロー

```text
障害発生・監視閾値超過
        ↓
Zabbixによる検知
        ↓
Trigger発報
        ↓
メール通知
        ↓
Linuxコマンドによる原因調査
        ↓
復旧対応
        ↓
動作確認
        ↓
ZabbixでRESOLVEDを確認
```

---

## Status

**Work in Progress**
