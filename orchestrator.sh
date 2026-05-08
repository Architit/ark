#!/bin/bash
LOG_FILE="/root/ark/logs/ark_event_journal.log"
MANIFEST_DIR="/root/ark/logs/manifests"
mkdir -p "$MANIFEST_DIR"

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
        log_event "Протокол оживления: Sentinel-0."
        pm2 start /root/radriloniuma.ark/core/sentinel.py --name "Sentinel-0"
        pm2 save
        notify_android "Sentinel-0 запущен и мониторит сеть."
        ;;
    "logs")
        pm2 logs Sentinel-0 --lines 20 --nostream
        ;;
    "manifest")
        M_FILE="$MANIFEST_DIR/master_manifest_$(date +%Y%m%d_%H%M%S).json"
        echo "[MANIFEST] Сборка глобального состояния..."
        cat << JSON_EOF > "$M_FILE"
{
  "timestamp": "$(date)",
  "nodes": {
    "ark": "$(cd /root/ark && git rev-parse --short HEAD)",
    "logic": "$(cd /root/radriloniuma.ark && git rev-parse --short HEAD)",
    "mobile": "$(cd /root/trianiuma.ark && git rev-parse --short HEAD)"
  },
  "system": {
    "ram": "$(free -h | awk 'NR==2{print $3 "/" $2}')",
    "pm2_status": "active"
  }
}
JSON_EOF
        echo "[SUCCESS] Манифест создан: $M_FILE"
        read -p "[?] Экспортировать манифест в Android? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            BRIDGE="/sdcard/Download/ARK_Manifests"
            mkdir -p "$BRIDGE"
            SHARED="$BRIDGE/$(basename "$M_FILE")"
            cp "$M_FILE" "$SHARED"
            termux-share -a send "$SHARED"
        fi
        ;;
    "dashboard")
        echo -e "\e[1;34m--- ARK SYSTEM DASHBOARD ---\e[0m"
        pm2 status
        echo -e "\e[1;33m[LAST EVENTS]\e[0m"
        tail -n 5 "$LOG_FILE"
        ;;
    "status")
        tail -n 10 "$LOG_FILE"
        ;;
    *)
        echo "Usage: ark {revive|logs|manifest|dashboard|status}"
        ;;
esac
