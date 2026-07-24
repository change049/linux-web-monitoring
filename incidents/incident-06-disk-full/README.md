# 障害対応記録 06：ディスク容量不足（No space left on device）

## 1. 障害概要

| 項目 | 内容 |
|---|---|
| 対象 | `/mnt/disk-full-test` |
| ファイルシステム | ext4（loopデバイス） |
| 障害種別 | ディスク容量不足 |
| 発生事象 | ファイル書き込み時に `No space left on device` が発生 |
| 影響 | 対象ファイルシステムへ新規データを書き込めない |

> 本検証では、OSのルート領域を保護するため、独立したloopデバイスを使用した。

---

## 2. 障害の再現

検証用ファイルシステムの空き容量を確認した。

```bash
df -h /mnt/disk-full-test
```

大容量ファイルを書き込み、ディスクを満杯にした。

```bash
dd if=/dev/zero   of=/mnt/disk-full-test/bigfile   bs=1M count=300 status=progress
```

以下のエラーが発生した。

```text
dd: IO error: No space left on device
```

---

## 3. 確認手順

### 3.1 使用率の確認

```bash
df -hT /mnt/disk-full-test
```

確認結果：

```text
Filesystem   Type  Size  Used  Avail  Use%  Mounted on
/dev/loop16  ext4  172M  158M   136K  100%  /mnt/disk-full-test
```

`Use%` が `100%` であることから、ディスク容量不足と判断した。

### 3.2 inode使用率の確認

```bash
df -ih /mnt/disk-full-test
```

確認結果では inode 使用率は約1%であった。

そのため、今回の原因はinode不足ではなく、データ容量の枯渇であると判断した。

### 3.3 使用量の大きいディレクトリを確認

```bash
sudo du -xhd1 /mnt/disk-full-test | sort -h
```

### 3.4 大容量ファイルを特定

```bash
sudo find /mnt/disk-full-test -xdev -type f   -printf '%s %p\n' | sort -rn | head
```

確認結果：

```text
164626432 /mnt/disk-full-test/bigfile
```

### 3.5 対象ファイルの確認

```bash
ls -lh /mnt/disk-full-test/bigfile
```

確認結果：

```text
-rw-rw-r-- 1 cao cao 157M ... /mnt/disk-full-test/bigfile
```

---

## 4. 原因

検証用の `bigfile` が約157MBの容量を使用し、172MBのファイルシステムを100%まで使用したため、追加書き込みができなくなった。

---

## 5. 対応

対象ファイルが検証用ファイルであることを確認した上で削除した。

```bash
rm -f /mnt/disk-full-test/bigfile
```

---

## 6. 復旧確認

```bash
df -hT /mnt/disk-full-test
```

確認結果：

```text
Filesystem   Type  Size  Used  Avail  Use%  Mounted on
/dev/loop16  ext4  172M  152K  158M  1%    /mnt/disk-full-test
```

使用率が100%から1%へ戻り、空き容量が確保されたことを確認した。

### スクリーンショット

![ディスク容量不足の調査と復旧](screenshots/01-disk-full-investigation-and-recovery.png)

---

## 7. 実務での確認ポイント

1. `df -hT` で容量不足のファイルシステムを特定する。
2. `df -ih` でinode不足ではないか確認する。
3. `du` と `find` で容量を消費している場所を特定する。
4. ファイルの用途・所有者・更新日時を確認する。
5. 不要と確認できたファイルのみ削除する。
6. 削除後に `df -hT` で復旧を確認する。
7. 削除後も空き容量が戻らない場合は `sudo lsof +L1` を確認する。

---

## 8. 学習内容

- `No space left on device` は容量不足またはinode不足で発生する。
- `df -hT` と `df -ih` を組み合わせて原因を切り分ける。
- `du` はディレクトリ単位、`find` はファイル単位の調査に使用できる。
- 実務では、大容量ファイルを発見しても用途確認前に削除しない。
- loopデバイスを使うことで、OSのルート領域を危険にさらさず障害を再現できる。
