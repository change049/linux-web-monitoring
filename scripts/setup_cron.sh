#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

HEALTH_SCRIPT="$PROJECT_DIR/scripts/health_check.sh"
LOG_ANALYSIS_SCRIPT="$PROJECT_DIR/scripts/log_analysis.sh"
AUTO_RECOVER_SCRIPT="$PROJECT_DIR/scripts/auto_recover.sh"
BACKUP_SCRIPT="$PROJECT_DIR/scripts/backup.sh"

LOG_DIR="$PROJECT_DIR/logs"
TEMP_CRON="$(mktemp)"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

cleanup() {
    rm -f "$TEMP_CRON"
}

trap cleanup EXIT

log "Cron setup started."

mkdir -p "$LOG_DIR"

# Check required scripts
for script in \
    "$HEALTH_SCRIPT" \
    "$LOG_ANALYSIS_SCRIPT" \
    "$AUTO_RECOVER_SCRIPT" \
    "$BACKUP_SCRIPT"
do
    if [[ ! -f "$script" ]]; then
        log "ERROR: Script does not exist: $script"
        exit 1
    fi
done

# Ensure scripts are executable
chmod +x \
    "$HEALTH_SCRIPT" \
    "$LOG_ANALYSIS_SCRIPT" \
    "$AUTO_RECOVER_SCRIPT" \
    "$BACKUP_SCRIPT"

# Read current crontab
crontab -l 2>/dev/null > "$TEMP_CRON" || true

# Remove old managed section
sed -i '/# BEGIN LINUX WEB MONITORING/,/# END LINUX WEB MONITORING/d' "$TEMP_CRON"

# Append new cron jobs
cat >> "$TEMP_CRON" <<EOF

# BEGIN LINUX WEB MONITORING

# Every 5 minutes: health check
*/5 * * * * /bin/bash "$HEALTH_SCRIPT" >> "$LOG_DIR/health_check_cron.log" 2>&1

# Every 5 minutes: automatic recovery
*/5 * * * * /bin/bash "$AUTO_RECOVER_SCRIPT" >> "$LOG_DIR/auto_recover_cron.log" 2>&1

# Every hour: Nginx access log analysis
0 * * * * /bin/bash "$LOG_ANALYSIS_SCRIPT" >> "$LOG_DIR/log_analysis_cron.log" 2>&1

# Every day at 02:00: backup
0 2 * * * /bin/bash "$BACKUP_SCRIPT" >> "$LOG_DIR/backup_cron.log" 2>&1

# END LINUX WEB MONITORING

EOF

# Install new crontab
crontab "$TEMP_CRON"

log "Cron jobs installed successfully."

echo
echo "Current crontab:"
echo "----------------------------------------"
crontab -l
