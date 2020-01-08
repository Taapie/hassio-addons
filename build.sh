#!/usr/bin/env bash
set -e

# If on Travis CI, update Docker's configuration.
if [ "$TRAVIS" == "true" ]; then
   echo "Running on Travis"
   echo "Fixing docker storage on Travic CI..."
   mkdir /tmp/docker
   echo '{
      "experimental": true,
      "storage-driver": "overlay2"
   }' | sudo tee /etc/docker/daemon.json > /dev/null
   sudo service docker restart
   DATA_PATH="/data"
   PWD=$(pwd)
   extra_docker_args="--volume=/etc/docker/daemon.json:/etc/docker/daemon.json:ro --mount type=bind,src=/tmp/docker,dst=/var/lib/docker --volume=$PWD:$DATA_PATH:rw"
   extra_builder_args=""
fi

# If on HASS.IO make sure to use the share folder
if [ "$HASSIO_TOKEN" != "" ]; then
   echo "Running on Hass.io"
   DATA_PATH="/share/addon-build"
   rm -rf ${DATA_PATH} > /dev/null 2>&1
   mkdir -p ${DATA_PATH} > /dev/null 2>&1
   cp -pR . ${DATA_PATH}
   extra_docker_args="--volume=/mnt/data/supervisor/${DATA_PATH}:${DATA_PATH}:rw --volume=/var/run/docker.sock:/var/run/docker.sock:ro"
   extra_builder_args="--no-cache"
fi

if [ "$DATA_PATH" == "" ]; then 
   echo "Running on generic Docker machine"
   # Set general settings
   DATA_PATH="/data"
   PWD=$(pwd)
   extra_docker_args="--volume=/var/run/docker.sock:/var/run/docker.sock:ro --volume=$PWD:$DATA_PATH:rw"
   extra_builder_args="--no-cache"
fi

# Determine local machine architecture
LOCAL_ARCH=`uname -m`
if [[ $LOCAL_ARCH == "armv7l" ]]; then
  LOCAL_ARCH='armv7'
fi
if [[ $LOCAL_ARCH == "x86_64" ]]; then
  LOCAL_ARCH='amd64'
fi

archs="${ARCHS}"
for addon in "$@"; do
   echo "*****************************************************************************"
   echo "Building addon ${addon}... "
   if [[ ${BUILD} == "true" ]] || [[ -z ${TRAVIS_COMMIT_RANGE} ]] || git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep -v README.md | grep -q ${addon}; then
      if [ -z "$archs" ]; then
    	archs=$(jq -r '.arch // ["armv7", "armhf", "amd64", "aarch64", "i386"] | [.[] | "--" + .] | join(" ")' ${addon}/config.json)
      fi

      echo "============================================================================="
      docker run --rm --privileged ${extra_docker_args} --volume ~/.docker:/root/.docker homeassistant/${LOCAL_ARCH}-builder ${extra_builder_args} -t ${DATA_PATH}/${addon} ${archs}
   else
      echo "skipped - no important changes found for this addon"
   fi
done
