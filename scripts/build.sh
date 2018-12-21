#!/bin/bash
set -e
archs="${ARCHS}"
for addon in "$@"; do
   echo "*****************************************************************************"
   echo "Building addon ${addon}... "
   if [[ -z ${TRAVIS_COMMIT_RANGE} ]] || git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep -v README.md | grep -q ${addon}; then
      if [[ -z "$archs" ]]; then
         echo "Checking for archs in ${addon}/config.json..."
         archs=$(jq -r '.arch // ["armhf"] | join(" ")' ${addon}/config.json)
      fi

      echo "Using archs: ${archs}"

      for arch in ${archs}; do
         echo "============================================================================="
         docker run --rm --privileged -v ~/.docker:/root/.docker -v $(pwd)/${addon}:/data homeassistant/amd64-builder --${arch} -t /data --no-cache
      done
   else
      echo "skipped - no important change found for this addon"
   fi
done
