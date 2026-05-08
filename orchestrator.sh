#!/bin/bash
LOG_FILE="/root/ark/logs/ark_event_journal.log"

log_event() {
    EVENT_ID=$(date +%s | sha256sum | head -c 8)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ID:$EVENT_ID] $1" >> "$LOG_FILE"
}

notify_android() {
    if command -v termux-notification &> /dev/null; then
        termux-notification --title "ARK SYSTEM ALERT" --content "$1" --priority high
    fi
}

case "$1" in
    "scan")
        log_event "Запуск диагностики."
        python3 /root/radriloniuma.ark/core/scanner.py | tee /tmp/scan_res
        if grep -q "OFFLINE" /tmp/scan_res; then
            notify_android "Внимание! Обнаружены неактивные узлы в сети ARK."
        fi
        ;;
    "dashboard")
        echo -e "\e[1;34m--- ARK SYSTEM DASHBOARD ---\e[0m"
        echo "[TIME] $(date)"
        free -h | awk 'NR==2{printf "  - RAM Usage: %s / %s\n", $3,$2 }'
        echo -e "\e[1;32m[PROCESSES]\e[0m"
        pm2 status || echo "  PM2 Offline"
        echo -e "\e[1;33m[LAST EVENTS]\e[0m"
        tail -n 5 "$LOG_FILE"
        ;;
    "watch")
        echo "[WATCHER] Запуск фонового мониторинга. (Ctrl+C для выхода)"
        while true; do
            /root/ark/orchestrator.sh scan > /dev/null
            sleep 300
        done
        ;;
    "status")
        tail -n 10 "$LOG_FILE"
        ;;
    *)
        echo "Usage: ark {scan|dashboard|watch|status}"
        ;;
esac
