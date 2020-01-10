#!/usr/bin/env bash
set -e

export DOCKER_CLI_EXPERIMENTAL=enabled

for ADDON in "$@"; do
   echo "*****************************************************************************"
   echo "Building addon ${ADDON}... "
   if [[ ${BUILD} == "true" ]] || [[ -z ${TRAVIS_COMMIT_RANGE} ]] || git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep -v README.md | grep -q ${ADDON}; then
       ARCHS=$(jq -r '.arch // ["armv7", "armhf", "amd64", "aarch64", "i386"] | [.[] | .] | join(" ")' ${ADDON}/config.json)
       VERSION=$(jq -r '.version' ${ADDON}/config.json)
       IMAGE=$(jq -r '.image' ${ADDON}/config.json)

      for ARCH in $ARCHS; do
         echo "============================================================================="
	 echo "Build for architecture '$ARCH'"

         case "${ARCH}" in 
            amd64) PLATFORM=adm64 ;;
            armhf) PLATFORM=arm ;;
            armv7) PLATFORM=arm ;;
            aarch64) PLATFORM=arm64 ;;
            i386) PLATFORM=386 ;;
         esac
	 
         DOCKERFILE_LOCATION="${ADDON}/Dockerfile"
	 DOCKER_IMAGE=${IMAGE}
	 DOCKER_TAG=${VERSION}

	 BUILD_ARCH=${ARCH}
	 BUILD_VERSION=${VERSION}
         BUILD_FROM=$(jq -r ".build_from.${ARCH}" ${ADDON}/config.json)

	 env

         buildctl build --frontend dockerfile.v0 \
                        --frontend-opt platform=linux/${PLATFORM} \
                        --frontend-opt filename=${DOCKERFILE_LOCATION} \
                        --exporter image \
                        --exporter-opt name=docker.io/${DOCKER_IMAGE}:${DOCKER_TAG} \
                        --exporter-opt push=true \
                        --local dockerfile=. \
                        --local context=.	 
      done
   else
      echo "skipped - no important changes found for this addon"
   fi
done
