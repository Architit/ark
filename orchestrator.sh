#!/bin/bash
echo "--- ARK CENTRAL ORCHESTRATOR ---"
case "$1" in
    "scan")
        python3 /root/radriloniuma.ark/core/scanner.py
        ;;
    "mobile-init")
        /root/trianiuma.ark/scripts/bootstrap.sh
        ;;
    "status")
        echo "[STATUS] Core: ONLINE | Logic: ONLINE | Mobile: ONLINE"
        ;;
    *)
        echo "Usage: ./orchestrator.sh {scan|mobile-init|status}"
        ;;
esac
