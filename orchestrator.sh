#!/bin/bash
LOG_FILE="/root/ark/logs/ark_event_journal.log"
VAULT_DIR="/root/ark/vault"

log_event() {
    EVENT_ID=$(date +%s | sha256sum | head -c 8)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ID:$EVENT_ID] $1" >> "$LOG_FILE"
}

case "$1" in
    "health")
        echo -e "\e[1;34m--- ARK HEALTH REPORT ---\e[0m"
        pm2 status Sentinel-0
        echo -e "\e[1;32m[LAST SENTINEL ACTIVITY]\e[0m"
        tail -n 5 "$LOG_FILE" | grep "SENTINEL"
        ;;
    "query")
        echo "[QUERY] Поиск по ключевому слову: $2"
        grep -i "$2" "$LOG_FILE" || echo "Совпадений не найдено."
        ;;
    "revive")
        pm2 restart Sentinel-0 --update-env || pm2 start /root/radriloniuma.ark/core/sentinel.py --name "Sentinel-0"
        pm2 save
        ;;
    "manifest")
        M_FILE="/root/ark/logs/manifests/master_manifest_$(date +%Y%m%d_%H%M%S).json"
        cat << JSON_EOF > "$M_FILE"
{
  "timestamp": "$(date)",
  "nodes": {"ark": "$(cd /root/ark && git rev-parse --short HEAD)", "logic": "$(cd /root/radriloniuma.ark && git rev-parse --short HEAD)"},
  "system": {"ram": "$(free -h | awk 'NR==2{print $3 "/" $2}')", "pm2_status": "active"}
}
JSON_EOF
        echo "[SUCCESS] Манифест создан. Используй 'termux-share' для экспорта."
        ;;
    "dashboard")
        echo -e "\e[1;34m--- ARK SYSTEM DASHBOARD ---\e[0m"
        pm2 status
        free -h | awk 'NR==2{print "  RAM: " $3 "/" $2}'
        ;;
    *)
        echo "Usage: ark {health|query|revive|manifest|dashboard}"
        ;;
esac
