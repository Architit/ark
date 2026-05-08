#!/bin/bash
LOG_FILE="/root/ark/logs/ark_event_journal.log"

log_event() {
    EVENT_ID=$(date +%s | sha256sum | head -c 8)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ID:$EVENT_ID] $1" >> "$LOG_FILE"
}

case "$1" in
    "scan")
        log_event "Запуск глубокой диагностики с попыткой восстановления."
        python3 /root/radriloniuma.ark/core/scanner.py
        # Простая проверка: если порты закрыты (код выхода сканера может быть расширен),
        # здесь будет команда на перезапуск через PM2
        ;;
    "dashboard")
        echo "--- ARK SYSTEM DASHBOARD ---"
        echo "[TIME] $(date)"
        echo "[RESOURCES]"
        free -h | awk 'NR==2{printf "  - RAM: %s / %s (%.2f%%)\n", $3,$2,$3*100/$2 }'
        echo "[PROCESSES (PM2)]"
        pm2 status || echo "  [!] PM2 не активен."
        echo "[LAST LOGS]"
        tail -n 3 "$LOG_FILE"
        ;;
    "mobile-init")
        log_event "Инициализация мобильного узла."
        /root/trianiuma.ark/scripts/bootstrap.sh
        ;;
    "snapshot")
        log_event "Экстренный снэпшот системы."
        tar -czf "/root/ark/logs/snapshot_$(date +%Y%m%d_%H%M%S).tar.gz" /root/ark /root/radriloniuma.ark /root/trianiuma.ark 2>/dev/null
        echo "[SUCCESS] Снимок сохранен в logs/."
        ;;
    "status")
        tail -n 10 "$LOG_FILE"
        ;;
    *)
        echo "Usage: ./orchestrator.sh {scan|dashboard|mobile-init|snapshot|status}"
        ;;
esac
