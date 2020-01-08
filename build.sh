#!/bin/bash
set -e

# If on Travis CI, update Docker's configuration.
if [ "$TRAVIS" == "true" ]; then
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
else
   DATA_PATH="/share/addon-build"
   mkdir -p  ${DATA_PATH} > /dev/null 2>&1
   extra_docker_args="--volume=/mnt/data/supervisor/${DATA_PATH}:${DATA_PATH}:rw --volume=/var/run/docker.sock:/var/run/docker.sock:ro"
   extra_builder_args="--no-cache"
fi

# Determine locak machine architecture
LOCAL_ARCH=`uname -m`
if [[ $LOCAL_ARCH == "armv7l" ]]; then
  LOCAL_ARCH='armv7'
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
      if [ "$TRAVIS" != "true" ]; then
         rm -rf  ${DATA_PATH}/${addon} > /dev/null 2>&1
         cp -pR ${addon} ${DATA_PATH}
      fi
      docker run --rm --privileged ${extra_docker_args} --volume ~/.docker:/root/.docker homeassistant/${LOCAL_ARCH}-builder ${extra_builder_args} -t ${DATA_PATH}/${addon} ${archs}
   else
      echo "skipped - no important changes found for this addon"
   fi
done
