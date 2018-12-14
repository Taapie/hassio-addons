#!/bin/bash
set -e
archs="${ARCHS}"
for addon in "$@"; do
   echo -n "Building addon ${addon}... "
   #if [ -z ${TRAVIS_COMMIT_RANGE} ] || git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep -v README.md | grep -q ${addon}; then
      echo ""
      if [ -z "$archs" ]; then
         archs=$(jq -r '.arch // ["armhf", "amd64", "aarch64"] | join(" ")' ${addon}/config.json)
      fi

      for arch in ${archs}; do
         echo "Building for architecture: ${arch}..."
         docker run --rm --privileged -v ~/.docker:/root/.docker -v $(pwd)/${addon}:/data homeassistant/${arch}-builder --${arch} -t /data --no-cache
      done
   #else
   #   echo "skipped - no important change found for this addon"
   #fi
done
