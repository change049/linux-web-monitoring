#!/bin/bash
set -euo pipefail

LOGFILE="/home/cao/linux-web-monitoring/logs/health_check.log"
EMAIL="example@example.com"

mkdir -p "$(dirname "$LOGFILE")"

log(){
	echo "$(date '+%Y-%m-%d %H:%M:%S') -$1" >>"$LOGFILE"
}

check_nginx(){
	if ! systemctl is-active --quiet nginx;then
	log "ERROR: nginx isn't running"
	echo "the system has error on $(hostname)" | mail -s "ALERT: nginx down" "$EMAIL"
       return 1	
	fi
	log "OK:nginx is active"
	
}

check_disk(){
	USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
	if [ "$USAGE" -gt 80 ]; then
		log "WARNING:disk usage is ${USAGE}%"
		echo "Disk ${USAGE} on $(hostname)" | mail -s "ALERT DISK USAGE HIGH" "$EMAIL"
	fi
}

check_port(){
	if ! ss -lntH 'sport = :80' | grep -q .; then
	log "ERROR:PORT 80 is not listening"
	return 1
	fi
	log "OK:PORT 80 is listening"
}

main() {
    local status=0

    check_nginx || status=1
    check_disk  || status=1
    check_port  || status=1

    exit "$status"
}

main
