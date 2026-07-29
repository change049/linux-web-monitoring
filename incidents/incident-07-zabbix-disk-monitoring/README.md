# Incident 07 - Zabbixによるディスク使用率監視

## 概要

Zabbixの公式テンプレート（Linux by Zabbix agent）を利用して、Linuxサーバーのディスク使用率を監視しました。

ディスク使用率が **85%** に達した際にトリガーが **PROBLEM** となり、VMwareの仮想ディスクを19GBから30GBへ拡張後、使用率は **55%** まで低下し、自動的に **RESOLVED** へ復旧することを確認しました。

---

## 環境

- Ubuntu 26.04
- Zabbix 7.x
- Zabbix Agent2
- VMware Fusion

---

## 調査

実施したコマンド

```bash
df -h
df -i
du -sh /* | sort -hr
find / -type f -size +500M
```

---

## 対応

```text
VMware Disk
19GB → 30GB
```

```bash
sudo growpart /dev/nvme0n2 2
sudo resize2fs /dev/nvme0n2p2
```

---

## 結果

- ディスク使用率：85% → 55%
- Trigger：PROBLEM → RESOLVED
- LLDによるファイルシステム自動検出を確認

---

## スクリーンショット

- Latest Data
- Trigger (PROBLEM)
- Trigger (RESOLVED)

---

## 習得した技術

- Zabbix監視
- LLD（Low-Level Discovery）
- Linuxディスク調査
- VMwareディスク拡張
- ext4ファイルシステム拡張
