#!/usr/bin/env bash
set -e

if [[ $CONFIG == "" ]]; then
   echo Using default config file
   CONFIG="config.json"
fi

ADDON=$1
CMD=$2
echo "*****************************************************************************"
echo "Runing addon ${ADDON}... "
echo "*****************************************************************************"
if [[ -f "${ADDON}/${CONFIG}" ]]; then 
   VERSION=$(jq -r '.version' ${ADDON}/${CONFIG})
   IMAGE=$(jq -r '.image' ${ADDON}/${CONFIG})

   EXTRA_DOCKER_ARGS=""

   HOST_NETWORK=$(jq -r '.host_network' ${ADDON}/${CONFIG})
   if [[ ${HOST_NETWORK,,} == "true" ]]; then
      EXTRA_DOCKER_ARGS="--net host $EXTRA_DOCKER_ARGS"
   fi

   FULL_ACCESS=$(jq -r '.full_access' ${ADDON}/${CONFIG})
   if [[ ${FULL_ACCESS,,} == "true" ]]; then
      EXTRA_DOCKER_ARGS="--privileged $EXTRA_DOCKER_ARGS"
   fi

   MAP=$(jq -r '.map' ${ADDON}/${CONFIG})
   if [[ $MAP != "null" ]]; then
      MAPS=$(jq -r '.map | .[]' ${ADDON}/${CONFIG})
      for MAP in $MAPS; do
         MAP=(${MAP//:/ })

	 case ${MAP[0]} in
	    config) HASSIO_PATH='/mnt/data/supervisor/homeassistant' && MOUNT_PATH='/config' ;;
	    ssl) HASSIO_PATH='/mnt/data/supervisor/ssl' && MOUNT_PATH='/ssl' ;;
	    addons) HASSIO_PATH='/mnt/data/supervisor/addons/local' && MOUNT_PATH='/addons' ;;
	    backup) HASSIO_PATH='/mnt/data/supervisor/backup' && MOUNT_PATH='/backup' ;;
	    share) HASSIO_PATH='/mnt/data/supervisor/share' && MOUNT_PATH='/share' ;;
	    *) echo "Invalid map value ${MAP[0]}" && exit 1 ;;
	 esac

         if [[ ${MAP[1]} ]]; then
	    MOUNT_OPTIONS=${MAP[1]}
	 else
	    MOUNT_OPTIONS="ro"
	 fi

         EXTRA_DOCKER_ARGS="-v $HASSIO_PATH:$MOUNT_PATH:$MOUNT_OPTIONS $EXTRA_DOCKER_ARGS"
      done
   fi

   PORTS=$(jq -r '.ports' ${ADDON}/${CONFIG})
   if [[ $PORTS != "null" ]]; then
      PORTS=$(jq -r '.ports | to_entries[] | "\(.key):\(.value)"' ${ADDON}/${CONFIG})
      for PORT in $PORTS; do
         PORT=(${PORT//:/ })

	 if [[ ${PORT[0]} != "" ]] && [[ ${PORT[1]} != "" ]] && [[ ${PORT[1]} != "null" ]]; then
            EXTRA_DOCKER_ARGS="-p ${PORT[1]}:${PORT[0]} $EXTRA_DOCKER_ARGS"
	 fi
      done
   fi

   docker run -it $EXTRA_DOCKER_ARGS ${IMAGE}:${VERSION} ${CMD}
else
   echo "skipped - missing ${CONFIG}" 
fi
echo "*****************************************************************************"
