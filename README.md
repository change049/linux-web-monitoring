# Linux Web Server 運用監視プロジェクト
[![CI](https://github.com/change049/linux-web-monitoring/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/change049/linux-web-monitoring/actions/workflows/ci.yml)

## 概要

Ubuntu上にNginx Webサーバーを構築し、Shell Script、cron、Zabbixを利用した運用監視環境を構築しました。

Linuxインフラ運用業務を想定し、サーバー監視、自動化、バックアップ、デプロイ、障害対応、アラート通知までの一連の運用を実践しています。

---

## プロジェクトの成果

- Bashによるヘルスチェック、バックアップ、ログ分析、デプロイ、自動復旧を実装
- Zabbix Agent 2でNginx、ディスク使用率、SSL証明書を監視
- Trigger発報からメール通知、復旧、RESOLVEDまでの運用フローを確認
- NginxおよびLinuxの障害を8種類再現し、原因調査と復旧手順を記録
- GitHub ActionsでShell ScriptとDocker Composeを自動チェック
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

## Quick Start

### 1. リポジトリを取得

```bash
git clone https://github.com/change049/linux-web-monitoring.git
cd linux-web-monitoring
```

### 2. Shell Scriptを実行

```bash
chmod +x scripts/*.sh

sudo ./scripts/health_check.sh
sudo ./scripts/backup.sh
sudo ./scripts/deploy.sh
```

ログ分析：

```bash
sudo ./scripts/log_analysis.sh
```

cron設定：

```bash
./scripts/setup_cron.sh
```

### 3. Zabbix監視環境を起動

```bash
cd configs/docker
cp .env.example .env
docker compose up -d
docker compose ps
```

Zabbix Web：

```text
http://localhost:8080
```

Zabbix Agent 2では、以下のUserParameterを使用します。

```text
nginx.status
nginx.active.connections
```

詳細設定：

* [Zabbix構築・監視設定](docs/zabbix/README.md)

### 4. 障害シミュレーション

Nginx、ポート、権限、PHP-FPM、ディスク容量、SSL証明書などの障害を再現し、原因調査と復旧確認を行います。

各手順：

* [Incident Simulation](#incident-simulation)

> 障害シミュレーションは検証用環境で実施してください。

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
│   
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
