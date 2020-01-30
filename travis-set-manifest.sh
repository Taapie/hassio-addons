#!/usr/bin/env bash
set -e

export DOCKER_CLI_EXPERIMENTAL=enabled

arch_to_platform () {
   case "$1" in 
      aarch64) PLATFORM=arm64 ;;
      amd64) PLATFORM=amd64 ;;
      armhf) PLATFORM=arm ;;
      armv7) PLATFORM=arm ;;
      i386) PLATFORM=386 ;;
      *) echo "Unknown architecture '${ARCH}'"; exit 1 ;;
   esac

   echo $PLATFORM
}

if [[ $CONFIG == "" ]]; then
   echo Using default config file
   CONFIG="config.json"
fi

for ADDON in "$@"; do
   if [[ ${BUILD,,} == "true" ]] || [[ -z ${TRAVIS_COMMIT_RANGE} ]] || git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep -v README.md | grep -q ${ADDON}; then
      echo "============================================================================="
      echo "Setting manifest for addon $ADDON"
      if [[ -f "${ADDON}/${CONFIG}" ]]; then 
         if [[ $ARCHS == "" ]]; then
            ARCHS=$(jq -r '.arch // ["aarch64", "amd64", "armv7", "armhf", "i386"] | [.[] | .] | sort | join(" ")' ${ADDON}/${CONFIG})
	 fi
         VERSION=$(jq -r '.version' ${ADDON}/${CONFIG})
         IMAGE=$(jq -r '.image' ${ADDON}/${CONFIG})

	 DOCKER_IMAGES=""
         for ARCH in $ARCHS; do
            PLATFORM=`arch_to_platform ${ARCH}`
	 
	    DOCKER_IMAGE=${IMAGE}
	    DOCKER_TAG="${VERSION}-${PLATFORM}"

	    if [[ $DOCKER_IMAGES == *" $DOCKER_IMAGE:$DOCKER_TAG "* ]]; then
               echo "skipped - platform '${PLATFORM}' has already been set" 
            else
               DOCKER_IMAGES="$DOCKER_IMAGES $DOCKER_IMAGE:$DOCKER_TAG "
            fi
         done

         if [[ $DOCKER_IMAGES != "" ]]; then
	    echo "Architectures '$ARCHS'"
	    docker manifest create $IMAGE:$VERSION $DOCKER_IMAGES
            for DOCKER_IMAGE in $DOCKER_IMAGES; do
               PLATFORM=${DOCKER_IMAGE##*-}
               docker manifest annotate $IMAGE:$VERSION $DOCKER_IMAGE --arch $PLATFORM
            done
            docker manifest push $IMAGE:$VERSION
         fi
      else
         echo "skipped - missing ${CONFIG}" 
      fi
   else
      echo "skipped - no important changes found for this addon"
   fi
done
