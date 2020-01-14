#!/usr/bin/env bash
cd /data/tuya-convert
mkdir -p /config/tuya-convert/backups > /dev/null 2>&1
ln -s /config/tuya-convert/backups backups
touch scripts/eula_accepted
./start_flash.sh
