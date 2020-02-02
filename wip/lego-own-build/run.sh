#!/usr/bin/env bash
set +u

CONFIG_PATH=/data/options.json

EMAIL=$(jq -r -c '.email' $CONFIG_PATH)
DOMAINS=$(jq -r -c '.domains[]' $CONFIG_PATH)
DNS=$(jq -r -c '.dns?' $CONFIG_PATH)
ENVS=$(jq -r -c '.env[]' $CONFIG_PATH)
INTERVAL=$(jq -r -c '.interval' $CONFIG_PATH)

for DOMAIN in $DOMAINS; do
   LEGO_DOMAINS="${LEGO_DOMAINS} -d $DOMAIN"
done

for ENV in $ENVS; do
   LEGO_ENVS="$LEGO_ENVS $ENV"
done

CMD="$LEGO_ENVS lego -a --path=\"/config/lego\" --email=\"$EMAIL\" $LEGO_DOMAINS --dns=\"$DNS\" run"

mkdir -p /config/lego > /dev/null 2>&1
mkdir -p /ssl/lego > /dev/null 2>&1

while true; do
  eval $CMD

  echo Copying certificates to /ssl/lego...
  cp /config/lego/certificates/*.crt /ssl/lego > /dev/null 2>&1
  cp /config/lego/certificates/*.key /ssl/lego > /dev/null 2>&1

  echo Sleeping for $INTERVAL hours...
  sleep ${INTERVAL}h
done

