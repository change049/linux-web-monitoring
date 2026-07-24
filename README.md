# Linux Web Server 運用監視プロジェクト

## 概要

Ubuntu 上に Nginx Web サーバーを構築し、Shell Script と Zabbix を利用した運用監視環境を構築するプロジェクトです。

Linux インフラエンジニアの日常業務を想定し、サーバー監視、自動化、バックアップ、障害復旧、デプロイ、および監視運用を実践します。

---

## 主な機能

- Nginx Web サーバー構築
- ヘルスチェック自動化
- アクセスログ分析
- バックアップ自動化
- サービス自動復旧
- デプロイ自動化
- Zabbix 監視
- 障害対応手順書

---

## 現在の進捗

- [x] Nginx インストール
- [x] カスタム Server Block 作成
- [x] Web ページ作成
- [x] HTTP 動作確認
- [x] UFW 設定
- [x] ヘルスチェックスクリプト
- [x] アクセスログ分析スクリプト
- [x] バックアップスクリプト
- [x] サービス自動復旧スクリプト
- [x] デプロイスクリプト
- [x] cron による定期実行
- [ ] Zabbix 監視
- [ ] 障害シミュレーション
- [ ] 障害対応手順書

---

## ディレクトリ構成

```text
linux-web-monitoring/
├── scripts/
│   ├── health_check.sh
│   ├── log_analysis.sh
│   ├── backup.sh
│   ├── auto_recovery.sh
│   └── deploy.sh
├── docs/
├── screenshots/
├── backup/
├── logs/
└── README.md
```

---

## 使用技術

- Ubuntu
- Nginx
- Bash (Shell Script)
- cron
- systemd
- UFW
- Zabbix

---

## 今後の予定


- Zabbix アラートとの連携
- 障害シミュレーションの追加
- 運用ドキュメントの整備

---

## Status

Work in Progress
## Incident Simulation

1. [Port Conflict](incidents/incident-01-port-conflict/)
2. [Nginx Syntax Error](incidents/incident-02-nginx-syntax-error/)
3. [403 Forbidden](incidents/incident-03-403-forbidden/)
4. [502 Bad Gateway](incidents/incident-04-502-bad-gateway/)
5. [504 Gateway Time-out](incidents/incident-05-504-gateway-timeout/)
6. [Disk Full](incidents/incident-06-disk-full/)
