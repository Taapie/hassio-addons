#!/usr/bin/env bash
set -e

PWD=`pwd`

if [[ $CONFIG == "" ]]; then
   echo Using default config file
   CONFIG="config.json"
fi

ADDON=$1
CMD=$2
echo "*****************************************************************************"
echo "Running addon ${ADDON}... "
ADDON_DIR="${PWD}/${ADDON}"
if [[ -f "${ADDON_DIR}/${CONFIG}" ]]; then 
   VERSION=$(jq -r '.version' ${ADDON_DIR}/${CONFIG})
   IMAGE=$(jq -r '.image' ${ADDON_DIR}/${CONFIG})

   EXTRA_DOCKER_ARGS=""

   HOST_NETWORK=$(jq -r '.host_network' ${ADDON_DIR}/${CONFIG})
   if [[ ${HOST_NETWORK,,} == "true" ]]; then
      EXTRA_DOCKER_ARGS="--net host $EXTRA_DOCKER_ARGS"
   fi

   FULL_ACCESS=$(jq -r '.full_access' ${ADDON_DIR}/${CONFIG})
   if [[ ${FULL_ACCESS,,} == "true" ]]; then
      EXTRA_DOCKER_ARGS="--privileged $EXTRA_DOCKER_ARGS"
   fi

   MAP=$(jq -r '.map' ${ADDON_DIR}/${CONFIG})
   if [[ $MAP != "null" ]]; then
      MAPS=$(jq -r '.map | .[]' ${ADDON_DIR}/${CONFIG})
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

   PORTS=$(jq -r '.ports' ${ADDON_DIR}/${CONFIG})
   if [[ $PORTS != "null" ]]; then
      PORTS=$(jq -r '.ports | to_entries[] | "\(.key):\(.value)"' ${ADDON_DIR}/${CONFIG})
      for PORT in $PORTS; do
         PORT=(${PORT//:/ })

	 if [[ ${PORT[0]} != "" ]] && [[ ${PORT[1]} != "" ]] && [[ ${PORT[1]} != "null" ]]; then
            EXTRA_DOCKER_ARGS="-p ${PORT[1]}:${PORT[0]} $EXTRA_DOCKER_ARGS"
	 fi
      done
   fi

   DEVICES=$(jq -r '.devices' ${ADDON_DIR}/${CONFIG})
   if [[ $DEVICES != "null" ]]; then
      DEVICES=$(jq -r '.devices | .[]' ${ADDON_DIR}/${CONFIG})
      for DEVICE in $DEVICES; do
         EXTRA_DOCKER_ARGS="--device=${DEVICE} $EXTRA_DOCKER_ARGS"
      done
   fi

   echo Command: docker run -it $EXTRA_DOCKER_ARGS ${IMAGE}:${VERSION} ${CMD}
   echo "*****************************************************************************"
   docker run -it $EXTRA_DOCKER_ARGS ${IMAGE}:${VERSION} ${CMD}
else
   echo "skipped - missing ${CONFIG}" 
fi
echo "*****************************************************************************"
