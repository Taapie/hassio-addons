#!/usr/bin/env bash
set -e

if ! [ -x "$(command -v buildctl)" ]; then
   echo 'Missing buildctl - can not build on this system' >&2
   exit 1
fi

export DOCKER_CLI_EXPERIMENTAL=enabled

arch_to_platform () {
   case "$1" in 
      amd64) PLATFORM=amd64 ;;
      armhf) PLATFORM=arm ;;
      armv7) PLATFORM=arm ;;
      aarch64) PLATFORM=arm64 ;;
      i386) PLATFORM=386 ;;
      *) echo "Unknown architecture '${ARCH}'"; exit 1 ;;
   esac

   echo $PLATFORM
}

for ADDON in "$@"; do
   echo "*****************************************************************************"
   echo "Building addon ${ADDON}... "
   if [[ ${BUILD,,} == "true" ]] || [[ -z ${TRAVIS_COMMIT_RANGE} ]] || git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep -v README.md | grep -q ${ADDON}; then
      if [[ -f "${ADDON}/config.json" ]] || [[ -f "${ADDON}/build.json" ]]; then 
         ARCHS=$(jq -r '.arch // ["armv7", "armhf", "amd64", "aarch64", "i386"] | [.[] | .] | join(" ")' ${ADDON}/config.json)
         VERSION=$(jq -r '.version' ${ADDON}/config.json)
         IMAGE=$(jq -r '.image' ${ADDON}/config.json)

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
               BUILD_FROM=$(jq -r ".build_from .${ARCH}" ${ADDON}/build.json)

               if [[ ${BUILD_FROM} == "" ]]; then 
                  echo "skipped - missing BUILD config in build.json for '${ARCH}'"
               else
                  buildctl build --frontend dockerfile.v0 \
                                 --local dockerfile=${ADDON} \
                                 --local context=${ADDON} \
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

         if [[ $DOCKER_IMAGES != "" ]]; then
	    docker manifest create $IMAGE:$VERSION $DOCKER_IMAGES
            for DOCKER_IMAGE in $DOCKER_IMAGES; do
               PLATFORM=${DOCKER_IMAGE##*-}
               if [[ $PLATFORM == "arm" ]]; then
                  docker manifest annotate $IMAGE:$VERSION $DOCKER_IMAGE --arch arm/v6
                  docker manifest annotate $IMAGE:$VERSION $DOCKER_IMAGE --arch arm/v7
               else
                  docker manifest annotate $IMAGE:$VERSION $DOCKER_IMAGE --arch $PLATFORM
               fi		      
            done
            docker manifest push $IMAGE:$VERSION
         fi
      else
         echo "skipped - missing config.json or build.json" 
      fi
   else
      echo "skipped - no important changes found for this addon"
   fi
done
