#!/bin/bash
LOG_FILE="/root/ark/logs/ark_event_journal.log"

log_event() {
    EVENT_ID=$(date +%s | sha256sum | head -c 8)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ID:$EVENT_ID] $1" >> "$LOG_FILE"
}

notify_android() {
    if command -v termux-notification &> /dev/null; then
        termux-notification --title "ARK SYSTEM" --content "$1" --priority high
    fi
}

case "$1" in
    "revive")
        log_event "Запуск протокола воскрешения узлов."
        echo "[REVIVE] Оживление процессов через PM2..."
        pm2 start /root/radriloniuma.ark/core/sentinel.py --name "Sentinel-0"
        pm2 save
        notify_android "Протокол Revive выполнен. Узлы запущены."
        ;;
    "scan")
        log_event "Запуск диагностики."
        python3 /root/radriloniuma.ark/core/scanner.py | tee /tmp/scan_res
        if grep -q "OFFLINE" /tmp/scan_res; then
            notify_android "ALERT: Обнаружены неактивные узлы."
        fi
        ;;
    "dashboard")
        echo -e "\e[1;34m--- ARK SYSTEM DASHBOARD ---\e[0m"
        echo "[TIME] $(date)"
        free -h | awk 'NR==2{printf "  - RAM Usage: %s / %s\n", $3,$2 }'
        echo -e "\e[1;32m[PROCESSES (PM2)]\e[0m"
        pm2 status
        echo -e "\e[1;33m[LAST EVENTS]\e[0m"
        tail -n 5 "$LOG_FILE"
        ;;
    "stop-all")
        log_event "Принудительная остановка всех процессов."
        pm2 stop all && pm2 save
        ;;
    "status")
        tail -n 10 "$LOG_FILE"
        ;;
    *)
        echo "Usage: ark {revive|scan|dashboard|stop-all|status}"
        ;;
esac
