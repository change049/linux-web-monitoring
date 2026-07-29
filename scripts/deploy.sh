#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPTS_DIR")"

SOURCE_DIR="$PROJECT_DIR/web"
TARGET_DIR="/var/www/myapp"
NEW_DIR="/var/www/myapp.new"
OLD_DIR="/var/www/myapp.old"

LOG_FILE="$PROJECT_DIR/logs/deploy.log"
CHECK_URL="${CHECK_URL:-http://myapp.local}"

mkdir -p "$(dirname "$LOG_FILE")"

log(){
	echo "$(date '+%Y%m%d_%H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

rollback() {
    log "Starting rollback."

    if [[ ! -d "$OLD_DIR" ]]; then
        log "ERROR: Rollback directory does not exist."
        return 1
    fi

    rm -rf "$TARGET_DIR"
    mv "$OLD_DIR" "$TARGET_DIR"

    if ! systemctl reload nginx >>"$LOG_FILE" 2>&1; then
        log "ERROR: Failed to reload nginx."
        return 1
    fi

    log "Rollback completed."
    return 0
}

if [[ "$EUID" -ne 0 ]];then
	echo "ERROR:please run this scripts with sudo"
	exit 1
fi

log "deployment started."

if [[ ! -d "$SOURCE_DIR" ]];then
	log "ERROR:source dirctory does not exist."
	exit 1
fi

if [[ ! -f "$SOURCE_DIR/index.html" ]];then
	log "ERROR:index.html doer not exist."
	exit 1
fi

rm -rf "$NEW_DIR"
mkdir -p "$NEW_DIR"

rsync -a --delete "$SOURCE_DIR/" "$NEW_DIR/"

chown -R "www-data:www-data" "$NEW_DIR"

find "$NEW_DIR" -type d -exec chmod 755 {} \;
find "$NEW_DIR" -type f -exec chmod 644 {} \;
rm -rf "$OLD_DIR"

if [[ -d "$TARGET_DIR" ]];then
	mv "$TARGET_DIR" "$OLD_DIR"
fi

mv "$NEW_DIR" "$TARGET_DIR"

if ! nginx -t >> "$LOG_FILE" 2>&1;then
	log "ERROR:nginx configuration test failed"
	rollback
	exit 1
fi

if ! systemctl reload nginx >>"$LOG_FILE" 2>&1; then
    log "ERROR: Failed to reload nginx."
    rollback
    exit 1
fi

sleep 2

if ! curl --fail --silent --show-error --max-time 5 "$CHECK_URL" > /dev/null ;then
	log "ERROR:http verification failed"
	rollback
	exit 1
fi

log "HTTP verification succeeded"

rm -rf "$OLD_DIR"
log "depolyment completed successfully"

