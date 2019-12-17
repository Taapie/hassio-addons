#!/usr/bin/env bash
mkdir -p /data/logs
mkdir -p /data/data
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
