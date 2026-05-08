#!/bin/bash
LOG_FILE="/root/ark/logs/ark_event_journal.log"
VAULT_DIR="/root/ark/vault"

case "$1" in
    "dashboard")
        echo -e "\e[1;35m╔══════════════════════════════════════════╗\e[0m"
        echo -e "\e[1;35m║       ARK TOTAL CONTROL DASHBOARD        ║\e[0m"
        echo -e "\e[1;35m╚══════════════════════════════════════════╝\e[0m"
        echo -e "\e[1;34m[SYSTEM]\e[0m Uptime: $(uptime -p)"
        echo -e "\e[1;32m[PROCESSES]\e[0m"
        pm2 status | grep -E "name|Sentinel-0"
        ;;
    "secure")
        python3 /root/radriloniuma.ark/protocols/vavima/gate.py ;;
    "handshake")
        TOKEN=$(python3 /root/radriloniuma.ark/protocols/vavima/handshake.py)
        echo "$TOKEN" > /tmp/ark_session_token
        echo "[VAVIMA] Сессионный токен создан и сохранен." ;;
    "verify")
        if [ -f /tmp/ark_session_token ]; then
            python3 /root/radriloniuma.ark/protocols/vavima/gate.py $(cat /tmp/ark_session_token)
        else
            echo "[!] Сессия не инициализирована. Выполни: ark handshake"
        fi ;;
    "status")
        tail -n 10 "$LOG_FILE" ;;
    *)
        echo "Usage: ark {dashboard|secure|status}" ;;
esac
