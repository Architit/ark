#!/bin/bash
LOG_FILE="/root/ark/logs/ark_event_journal.log"

log_event() {
    # Генерация ID события и запись в лог
    EVENT_ID=$(date +%s | sha256sum | head -c 8)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ID:$EVENT_ID] $1" >> "$LOG_FILE"
}

case "$1" in
    "scan")
        log_event "Запуск сканирования портов."
        python3 /root/radriloniuma.ark/core/scanner.py
        ;;
    "mobile-init")
        log_event "Инициализация мобильного узла."
        /root/trianiuma.ark/scripts/bootstrap.sh
        ;;
    "snapshot")
        log_event "Создание снимка состояния системы."
        echo "[SNAPSHOT] Архивация состояний в /root/ark/logs/..."
        tar -czf "/root/ark/logs/snapshot_$(date +%Y%m%d_%H%M%S).tar.gz" /root/ark /root/radriloniuma.ark /root/trianiuma.ark 2>/dev/null
        echo "Снимок сохранен."
        ;;
    "status")
        echo "--- ПОСЛЕДНИЕ СОБЫТИЯ ARK ---"
        tail -n 10 "$LOG_FILE"
        ;;
    *)
        echo "Usage: ./orchestrator.sh {scan|mobile-init|snapshot|status}"
        ;;
esac
