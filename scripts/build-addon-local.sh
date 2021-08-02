#!/usr/bin/env bash
set -e

CONFIG="config.json"

# Determine local machine architecture
LOCAL_ARCH=`uname -m`
if [[ $LOCAL_ARCH == "armv7l" ]]; then
  LOCAL_ARCH='armv7'
fi
if [[ $LOCAL_ARCH == "x86_64" ]]; then
  LOCAL_ARCH='amd64'
fi

ARCHS="${LOCAL_ARCH}"
for ADDON in "$@"; do
   echo "*****************************************************************************"
   echo "Building addon ${ADDON}... "
      if [[ -f "${ADDON}/${CONFIG}" ]] && [[ -f "${ADDON}/build.json" ]]; then 
         VERSION=$(jq -r '.version' ${ADDON}/${CONFIG})
         IMAGE=$(jq -r '.image' ${ADDON}/${CONFIG})

         for ARCH in $ARCHS; do
            echo "============================================================================="
	    echo "Build for architecture '$ARCH'"

	    DOCKER_IMAGE=${IMAGE}
	    DOCKER_TAG="${VERSION}"

            BUILD_ARCH=${ARCH}
            BUILD_VERSION=${VERSION}
            BUILD_FROM=$(jq -r ".build_from .${ARCH}" ${ADDON}/build.json)

            if [[ ${BUILD_FROM} == "null" ]]; then 
               echo "skipped - missing BUILD config in build.json for '${ARCH}'"
            else
               docker build -t docker.io/${DOCKER_IMAGE}:${DOCKER_TAG} \
		            --build-arg BUILD_ARCH=${BUILD_ARCH} \
		            --build-arg BUILD_VERSION=${BUILD_VERSION} \
		            --build-arg BUILD_FROM=${BUILD_FROM} \
			    $ADDON
            fi
         done
      else
         echo "skipped - missing ${CONFIG} or build.json" 
      fi
done
