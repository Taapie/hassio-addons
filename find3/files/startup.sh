#!/usr/bin/env bash
cp -R -u -p /app/mosquitto_config /data
mosquitto -d -c /data/mosquitto_config/mosquitto.conf
mkdir -p /data/logs
/usr/bin/supervisord
