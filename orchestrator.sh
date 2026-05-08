#!/bin/bash
LOG_FILE="/root/ark/logs/ark_event_journal.log"
VAULT_DIR="/root/ark/vault"

log_event() {
    EVENT_ID=$(date +%s | sha256sum | head -c 8)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ID:$EVENT_ID] $1" >> "$LOG_FILE"
}

case "$1" in
    "sync")
        for node in /root/ark /root/radriloniuma.ark /root/trianiuma.ark; do
            echo "[SYNC] Узел: $node"
            cd $node && git pull origin ark-gen-phase-0
        done
        ;;
    "report")
        echo "--- ГЛОБАЛЬНЫЙ ОТЧЕТ ARK ---"
        echo "Аптайм системы: $(uptime -p)"
        echo "Событий в журнале: $(wc -l < $LOG_FILE)"
        echo "Объектов в Vault: $(ls $VAULT_DIR | wc -l)"
        ;;
    "telemetry")
        python3 /root/ark/telemetry/collector.py
        echo "[SUCCESS] Данные телеметрии записаны."
        ;;
    "dashboard")
        echo -e "\e[1;34m--- ARK SYSTEM DASHBOARD ---\e[0m"
        pm2 status
        free -h | awk 'NR==2{print "  RAM: " $3 "/" $2}'
        ;;
    "status")
        tail -n 10 "$LOG_FILE"
        ;;
    *)
        echo "Usage: ark {sync|report|telemetry|dashboard|status}"
        ;;
esac
