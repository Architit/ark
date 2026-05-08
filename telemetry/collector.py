import json
import time
import psutil
import os

TELEMETRY_LOG = "/root/ark/logs/telemetry.json"

def collect():
    data = {
        "timestamp": time.time(),
        "cpu": psutil.cpu_percent(),
        "memory": psutil.virtual_memory().percent,
        "disk": psutil.disk_usage('/').percent
    }
    with open(TELEMETRY_LOG, "a") as f:
        f.write(json.dumps(data) + "\n")

if __name__ == "__main__":
    collect()
