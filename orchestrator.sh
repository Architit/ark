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
    "ignite")
        echo "[SYSTEM] Активация Mesh-сети..."
        pm2 start /root/radriloniuma.ark/core/gateway_mock.py --name "Autopilot-8765" -- 8765 Autopilot
        pm2 start /root/radriloniuma.ark/core/gateway_mock.py --name "Gateway-8766" -- 8766 MCP_Gateway
        pm2 start /root/radriloniuma.ark/core/gateway_mock.py --name "Mesh-8767" -- 8767 Mesh_Server
        pm2 save ;;
    "pulse")
        if [ -f /tmp/ark_session_token ]; then
            python3 /root/radriloniuma.ark/core/sentinel.py $(cat /tmp/ark_session_token)
        else
            echo "[!] Нет токена. ark handshake"
        fi ;;
    "archive")
        echo "[SYSTEM] Архивация и Omni-Backup..."
        A_FILE="/root/ark/logs/ARK_SESSION_$(date +%Y%m%d_%H%M%S).tar.gz"
        tar -czf "$A_FILE" /root/ark/logs/*.log /root/ark/logs/manifests/*.json
        bash /root/ark/telemetry/backup_manager.sh "$A_FILE"
        echo "[SUCCESS] Omni-Persistence завершен." ;;
    "status")
        tail -n 10 "$LOG_FILE" ;;
    *)
        echo "Usage: ark {dashboard|secure|status}" ;;
esac
