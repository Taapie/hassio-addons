#!/usr/bin/env bash
set -e

export DOCKER_CLI_EXPERIMENTAL=enabled

for ADDON in "$@"; do
   echo "*****************************************************************************"
   echo "Building addon ${ADDON}... "
   if [[ ${BUILD,,} == "true" ]] || [[ -z ${TRAVIS_COMMIT_RANGE} ]] || git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep -v README.md | grep -q ${ADDON}; then
      if [[ -f "${ADDON}/config.json" ]] || [[ -f "${ADDON}/build.json" ]]; then 
         ARCHS=$(jq -r '.arch // ["armv7", "armhf", "amd64", "aarch64", "i386"] | [.[] | .] | join(" ")' ${ADDON}/config.json)
         VERSION=$(jq -r '.version' ${ADDON}/config.json)
         IMAGE=$(jq -r '.image' ${ADDON}/config.json)

         for ARCH in $ARCHS; do
            echo "============================================================================="
	    echo "Build for architecture '$ARCH'"

            case "${ARCH}" in 
               amd64) PLATFORM=amd64 ;;
               armhf) PLATFORM=arm ;;
               armv7) PLATFORM=arm ;;
               aarch64) PLATFORM=arm64 ;;
               i386) PLATFORM=386 ;;
	       *) echo "Unknown architecture '${ARCH}'"; exit 1 ;;
            esac
	 
	    DOCKER_IMAGE=${IMAGE/\{arch\}/$ARCH}
	    DOCKER_TAG=${VERSION}

	    BUILD_ARCH=${ARCH}
	    BUILD_VERSION=${VERSION}
            BUILD_FROM=$(jq -r ".build_from .${ARCH}" ${ADDON}/build.json)

            if [[ ${BUILD_FROM} == "" ]]; then 
               echo "skippe - missing BUILD config in build.json for '${ARCH}'"
            else
               buildctl build --frontend dockerfile.v0 \
                              --local dockerfile=${ADDON} \
                              --local context=${ADDON} \
                              --output type=image,name=docker.io/${DOCKER_IMAGE}:${DOCKER_TAG},push=true \
                              --opt platform=linux/${PLATFORM} \
                              --opt filename=Dockerfile \
	                      --opt build-arg:BUILD_ARCH=${BUILD_ARCH} \
	                      --opt build-arg:BUILD_VERSION=${BUILD_VERSION} \
	                      --opt build-arg:BUILD_FROM=${BUILD_FROM} 
            fi
         done
      else
         echo "skipped - missing config.json or build.json" 
      fi
   else
      echo "skipped - no important changes found for this addon"
   fi
done
