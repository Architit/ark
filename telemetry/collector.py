import json, time, psutil, sys, os
from radriloniuma.ark.protocols.vavima.gate import verify_token

def collect(token):
    if verify_token(token):
        data = {"timestamp": time.time(), "cpu": psutil.cpu_percent(), "memory": psutil.virtual_memory().percent}
        with open("/root/ark/logs/telemetry.json", "a") as f:
            f.write(json.dumps(data) + "\n")
        print("[SUCCESS] Данные защищены и записаны.")
    else:
        print("[ACCESS DENIED] Невалидный токен VAVIMA.")

if __name__ == "__main__":
    if len(sys.argv) > 1: collect(sys.argv[1])
