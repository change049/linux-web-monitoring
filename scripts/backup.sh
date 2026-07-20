#!/bin/bash	
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPTS_DIR")"

BACKUP_DIR="$PROJECT_DIR/backup"
LOG_FILE="$PROJECT_DIR/logs/backup.log"
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
RETENTION_DAYS="7"
BACKUP_FILE="$BACKUP_DIR/web_backup_${TIMESTAMP}.tar.gz"

log(){
	echo "$(date '+%Y%m%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
	
}

if [[ "$EUID" -ne 0 ]]; then
	echo "ERROR:please use scripts with sudo"
	exit 1
fi

mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$BACKUP_FILE")"

log "backup started."

if [[ ! -d /etc/nginx ]]; then
	echo "ERROR:/etc/nignx does not exist"
	exit 1
fi

if [[ ! -d /var/www/myapp ]]; then
	echo "ERROR:/var/www/myapp does not exist"
	exit t1
fi

tar -czf "$BACKUP_FILE" -C /etc/nginx /var/www/myapp

if [[ ! -s "$BACKUP_FILE" ]]; then
	echo "ERROR:backup file does not created"
	exit 1
fi

sha256sum "$BACKUP_FILE" > "$BACKUP_FILE.sha256"
BACKUP_SIZE="$(du -h "$BACKUP_FILE" | awk '{print $1}')"

log "backup completed:$BACKUP_FILE"
log "backup size:$BACKUP_SIZE"

find "$BACKUP_DIR" -type f -name "web_backup_*.tar.gz" -o -name "web_backup_*.tar.gz.sha256"\
-mtime "+$RETENTION_DAYS" -delete

log "old backup older than $RETENTION_DAYS were deleted"
