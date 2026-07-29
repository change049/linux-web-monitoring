# Incident 08 - ZabbixによるSSL証明書有効期限監視

## 概要

Zabbixの公式テンプレート  
`Website certificate by Zabbix agent 2` を使用し、Nginxで公開している `myapp.local` のSSL証明書を監視しました。

有効期限3日のテスト証明書を設定し、期限切れまで7日未満になった際に、Zabbixでアラートを発生させ、メール通知を送信しました。

その後、365日有効な証明書へ更新し、アラートが自動的に復旧することを確認しました。

---

## 環境

- Ubuntu 26.04
- Nginx
- Zabbix 7.4
- Zabbix Agent 2
- OpenSSL
- VMware Fusion

---

## 監視内容

監視対象：

```text
https://myapp.local
