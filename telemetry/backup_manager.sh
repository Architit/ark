#!/bin/bash
ARCHIVE_PATH=$1
TARGET_DIR="/ARK"

log_backup() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BACKUP] $1" >> /root/ark/logs/ark_event_journal.log
}

# Функция проверки и создания папки
ensure_dir() {
    local path=$1
    if [ ! -d "$path" ]; then
        mkdir -p "$path" && log_backup "Создана директория: $path"
    fi
}

# 1. ЛОКАЛЬНЫЕ И СЪЕМНЫЕ НОСИТЕЛИ (SD-карта, USB, Монтированные диски)
LOCATIONS=("/sdcard/Download" "/storage/emulated/0" "/mnt/media_rw" "/media/root")

for loc in "${LOCATIONS[@]}"; do
    if [ -d "$loc" ] && [ -w "$loc" ]; then
        ensure_dir "$loc$TARGET_DIR"
        cp "$ARCHIVE_PATH" "$loc$TARGET_DIR/" && log_backup "Скопировано в: $loc"
    fi
done

# 2. ОБЛАЧНЫЕ ХРАНИЛИЩА (через rclone)
# Предполагается, что конфиги rclone называются 'gdrive', 'yandex', 'onedrive'
CLOUDS=("gdrive" "yandex" "onedrive")
for cloud in "${CLOUDS[@]}"; do
    if rclone listremotes | grep -q "$cloud:"; then
        rclone mkdir "$cloud:$TARGET_DIR"
        rclone copy "$ARCHIVE_PATH" "$cloud:$TARGET_DIR" && log_backup "Загружено в облако: $cloud"
    else
        log_backup "Облако $cloud не настроено в rclone. Пропуск."
    fi
done
