#!/bin/bash
set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname  "$SCRIPT_DIR")"

ACCESS_LOG="/var/log/nginx/myapp_access.log"
REPORT_DIR="$PROJECT_DIR/reports"

REPORT_FILE="$REPORT_DIR/nginx_report_$(date '+%Y%m%d_%H%M%S').txt"

mkdir -p "$REPORT_DIR"

if [[ ! -f "$ACCESS_LOG" ]]; then
	echo "ERROR:log file dose not exist: $ACCESS_LOG"
	exit 1
fi

if [[ ! -s "$ACCESS_LOG" ]]; then
	echo "ERROR:access log is empty: $ACCESS_LOG"
	exit 1
fi

{
echo "============================================"
echo "Nginx access log analysis report"
echo "Generated $(date '+%Y-%m-%d %H:%M:%S')"
echo "log-file: $ACCESS_LOG"
echo "============================================"

echo
echo "[1]Total requests" 
wc -l < "$ACCESS_LOG"

echo 
echo "[2]Http status code distribution"
awk '{print $9}' "$ACCESS_LOG" | sort | uniq -c | sort -rn

echo
echo "[3]Top 10 client ip addresses"
awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -rn | head -10

echo
echo "[4]Top 10 requested urls"
awk '{print $7}' "$ACCESS_LOG" | sort | uniq -c | sort -rn | head -10

echo
echo "[5]Number of 4xx error"
awk '$9 ~ /^4/ {count++} END {print count+0}' "$ACCESS_LOG"

echo
echo "[6]Number of 5xx error"
awk '$9 ~ /^5/ {count++} END {print count+0}' "$ACCESS_LOG"

echo 
echo "Recent 10 error requests"
awk '$9 ~ /^[45]/ {print} ' "$ACCESS_LOG" | tail -10

} > "$REPORT_FILE"

echo "Log analysis is completed."
echo "REPORT:$REPORT_FILE"

