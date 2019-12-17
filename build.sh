#!/bin/bash
set -e

# If on Travis CI, update Docker's configuration.
if [ "$TRAVIS" == "true" ]; then
   echo "Fixing docker storage on Travic CI..."
   mkdir /tmp/docker
   sudo echo '{
      "experimental": true,
      "storage-driver": "overlay2"
   }' > /etc/docker/daemon.json
   sudo service docker restart
   extra_docker_args="--volume=/etc/docker/daemon.json:/etc/docker/daemon.json:ro --mount type=bind,src=/tmp/docker,dst=/var/lib/docker"
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
      docker run --rm --privileged ${extra_docker_args} -v ~/.docker:/root/.docker -v $(pwd)/${addon}:/data homeassistant/amd64-builder ${archs} -t /data 
   else
      echo "skipped - no important changes found for this addon"
   fi
done
