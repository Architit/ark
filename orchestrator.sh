#!/bin/bash
LOG_FILE="/root/ark/logs/ark_event_journal.log"
VAULT_DIR="/root/ark/vault"

log_event() {
    EVENT_ID=$(date +%s | sha256sum | head -c 8)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ID:$EVENT_ID] $1" >> "$LOG_FILE"
}

case "$1" in
    "sync")
        log_event "Глобальная синхронизация узлов."
        for node in /root/ark /root/radriloniuma.ark /root/trianiuma.ark; do
            echo "[SYNC] Проверка узла: $node"
            cd $node && git pull origin ark-gen-phase-0
        done
        ;;
    "health")
        echo -e "\e[1;34m--- ARK HEALTH REPORT ---\e[0m"
        pm2 status Sentinel-0
        echo -e "\e[1;32m[LAST SENTINEL ACTIVITY]\e[0m"
        tail -n 5 "$LOG_FILE" | grep "SENTINEL"
        ;;
    "heartbeat")
        log_event "Запуск проверки сердцебиения (Deep Scan)."
        python3 /root/radriloniuma.ark/core/sentinel.py --once
        ;;
    "dashboard")
        echo -e "\e[1;34m--- ARK SYSTEM DASHBOARD ---\e[0m"
        pm2 status
        free -h | awk 'NR==2{print "  RAM: " $3 "/" $2}'
        echo "[VAULT] Инвентаризация: $(ls $VAULT_DIR | wc -l) объектов."
        ;;
    "status")
        tail -n 10 "$LOG_FILE"
        ;;
    *)
        echo "Usage: ark {sync|health|heartbeat|dashboard|status}"
        ;;
esac
