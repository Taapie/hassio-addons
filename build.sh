#!/bin/bash
set -e
archs="${ARCHS}"
for addon in "$@"; do
   echo "*****************************************************************************"
   echo "Building addon ${addon}... "
   if [[ -z ${TRAVIS_COMMIT_RANGE} ]] || git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep -v README.md | grep -q ${addon}; then
      if [[ -z "$archs" ]]; then
         echo "Checking for archs in ${addon}/config.json..."
         archs=$(jq -r '.arch // ["armhf", "amd64", "aarch64", "i386"] | [.[] | "--" + .] | join(" ")' ${addon}/config.json)
      fi

      echo "Replacing {DATE}..."
      sed -i.bak "s/{DATE}/$(date '+%Y%m%d%H%M')/g" ${addon}/config.json

      echo "Using archs: ${archs}"

      echo "============================================================================="
      docker run --rm --privileged -v ~/.docker:/root/.docker -v $(pwd)/${addon}:/data homeassistant/amd64-builder ${archs} -t /data --no-cache

      echo "Reverting changes..."
      mv ${addon}/config.json.bak ${addon}/config.json
   else
      echo "skipped - no important changes found for this addon"
   fi
done
