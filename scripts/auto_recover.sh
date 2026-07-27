#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

LOG_FILE="$PROJECT_DIR/logs/auto_recover.log"
CHECK_URL="http://myapp.local"
MAX_TIME=5

#creat dir
mkdir -p "$(dirname "$LOG_FILE")"

log() {
	echo "$(date '+%Y%m%d_%H:%M:%S') - $1" | tee -a "$LOG_FILE"
	
}

CHECK_SERVICE(){
	systemctl is-active --quiet  nginx
}
	
CHECK_HTTP(){
	curl --fail --silent --show-error --max-time "$MAX_TIME" "$CHECK_URL" >/dev/null
}

recover_nginx(){
	log "Starting nginx recovering"

	if ! nginx -t >>"$LOG_FILE"2>&1 ; then
		log "ERROR:nginx configuration test failed"
		return 1
	fi
	
	log "nginx configuration is valid."

	if ! systemctl restart nginx; then
		log "ERROR:failed recover nginx"
		return 1
	fi

	sleep 2

	if ! CHECK_SERVICE; then
		log "ERROR:nginx is still inactive after restart."
		return 1
	fi

	if ! CHECK_HTTP; then
		log "ERROR:HTTP check still failed after restart."
		return 1
	fi

	log "nginx recovery completed successfully"
}

if [[ "$EUID" -ne 0 ]]; then
	echo "ERROR:Please run this scripts with sudo"
	exit 1
fi

service_ok=true
http_ok=true

if ! CHECK_SERVICE; then
	service_ok=false
	log "WARNING:nginx service is inactive"
fi

if ! CHECK_HTTP; then
	http_ok=false
	log "WARNING:http check is failed:$CHECK_URL"
fi

if [[ "$service_ok" == true && "$http_ok" == true ]]; then
	log "nginx service and http response are healthy"
	exit 0
fi

if recover_nginx; then
	log "auto recovery succeeded."
	exit 0
else
	log "CRITICAL:auto recovery failed"
	exit 1
fi
