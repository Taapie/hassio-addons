#!/usr/bin/env bash
set -e

PWD=`pwd`

if ! [ -x "$(command -v buildctl)" ]; then
   echo 'Missing buildctl - can not build on this system' >&2
   exit 1
fi

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
   ADDON_DIR="${PWD}/${ADDON}"

   echo "*****************************************************************************"
   echo "Building addon ${ADDON}... "
   if [[ ${BUILD,,} == "true" ]] || [[ -z ${TRAVIS_COMMIT_RANGE} ]] || git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep -v README.md | grep -q ${ADDON}; then
      if [[ -f "${ADDON_DIR}/${CONFIG}" ]] && [[ -f "${ADDON_DIR}/build.json" ]]; then 
         if [[ $ARCHS == "" ]]; then
            ARCHS=$(jq -r '.arch // ["aarch64", "amd64", "armv7", "armhf", "i386"] | [.[] | .] | sort | join(" ")' ${ADDON_DIR}/${CONFIG})
	 fi
         VERSION=$(jq -r '.version' ${ADDON_DIR}/${CONFIG})
         IMAGE=$(jq -r '.image' ${ADDON_DIR}/${CONFIG})

	 DOCKER_IMAGES=""
         for ARCH in $ARCHS; do
            echo "============================================================================="
	    echo "Build for architecture '$ARCH'"

            PLATFORM=`arch_to_platform ${ARCH}`
	 
	    DOCKER_IMAGE=${IMAGE}
	    DOCKER_TAG="${VERSION}-${PLATFORM}"

	    if [[ $DOCKER_IMAGES == *" $DOCKER_IMAGE:$DOCKER_TAG "* ]]; then
               echo "skipped - platform '${PLATFORM}' has already been build" 
            else
               DOCKER_IMAGES="$DOCKER_IMAGES $DOCKER_IMAGE:$DOCKER_TAG "

	       DOCKER_LATEST_TAG="latest-${PLATFORM}"

	       BUILD_ARCH=${ARCH}
	       BUILD_VERSION=${VERSION}
               BUILD_FROM=$(jq -r ".build_from .${ARCH}" ${ADDON_DIR}/build.json)

               if [[ ${BUILD_FROM} == "null" ]]; then 
                  echo "skipped - missing BUILD config in build.json for '${ARCH}'"
               else
                  buildctl build --frontend dockerfile.v0 \
                                 --local dockerfile=${ADDON_DIR} \
                                 --local context=${ADDON_DIR} \
                                 --output type=image,name=docker.io/${DOCKER_IMAGE}:${DOCKER_LATEST_TAG},push=true \
			         --export-cache type=inline \
			         --import-cache type=registry,ref=docker.io/${DOCKER_IMAGE}:${DOCKER_LATEST_TAG} \
                                 --opt platform=linux/${PLATFORM} \
                                 --opt filename=Dockerfile \
	                         --opt build-arg:BUILD_ARCH=${BUILD_ARCH} \
	                         --opt build-arg:BUILD_VERSION=${BUILD_VERSION} \
	                         --opt build-arg:BUILD_FROM=${BUILD_FROM} 

		  docker pull docker.io/${DOCKER_IMAGE}:${DOCKER_LATEST_TAG}
                  docker tag docker.io/${DOCKER_IMAGE}:${DOCKER_LATEST_TAG} docker.io/${DOCKER_IMAGE}:${DOCKER_TAG}
                  docker push docker.io/${DOCKER_IMAGE}:${DOCKER_TAG}
               fi
            fi
         done
      else
         echo "skipped - missing ${CONFIG} or build.json" 
      fi
   else
      echo "skipped - no important changes found for this addon"
   fi
done
