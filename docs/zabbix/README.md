# Zabbix Monitoring

## 概要

本プロジェクトでは、Zabbix 7.4 を利用して Linux サーバーおよび Nginx の監視環境を構築しました。

障害検知、メール通知、復旧確認まで、一連の監視運用を実施しています。

---

## 監視項目

- Nginx Service Status
- Nginx Active Connections
- Linux Filesystem Usage
- SSL Certificate Expiration
- SSL Certificate Validation
- SSL Certificate Fingerprint

---

## 通知

Trigger Action を利用し、以下のメール通知を設定しました。

- 障害発生（PROBLEM）
- 障害復旧（RESOLVED）

---

## 使用技術

- Zabbix Server 7.4
- Zabbix Agent 2
- Trigger
- Action
- Email Notification
- Low-Level Discovery (LLD)

---

## 関連インシデント

- Incident 07 - Zabbix Disk Space Monitoring
- Incident 08 - Zabbix SSL Certificate Monitoring
