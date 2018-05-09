#!/bin/bash
set -e
archs="${ARCHS}"
for addon in "$@"; do
   echo -n "Building addon ${addon}... "
   if [ -z ${TRAVIS_COMMIT_RANGE} ] || git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep -v README.md | grep -q ${addon}; then
      if [ -z "$archs" ]; then
         archs=$(jq -r '.arch // ["armhf", "amd64", "aarch64", "i386"] | [.[] | "--" + .] | join(" ")' ../${addon}/config.json)
      fi

      docker run --rm --privileged -v ~/.docker:/root/.docker -v $(pwd)/../${addon}:/data homeassistant/amd64-builder ${archs} -t /data --no-cache
      echo "done"
   else
      echo "skipped - no important change in commit range"
   fi
done