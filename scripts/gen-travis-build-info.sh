#!/usr/bin/env bash
set -e

PWD=`pwd`

EXTRA_ENV="$*"

BADGE_URL="https://badges.herokuapp.com/travis/Taapie/hassio-addons?branch=${BRANCH}&label=${LABEL}&env=ADDON=%22$ADDON%22%20ARCH=%22$ARCH%22"
BRANCH=`git branch --show-current`

BUILD_PART="    - stage: build\n      env:\n        - \$ENV\n      script:\n        - docker login -u \$DOCKER_USER -p \$DOCKER_PASSWORD\n        - ARCHS=\$ARCH ./scripts/travis-build.sh \$ADDON\n"

DONE_PART="    - stage: manifest\n      env:\n        - \$ENV\n      script:\n        - docker login -u \$DOCKER_USER -p \$DOCKER_PASSWORD\n        - ./scripts/travis-set-manifest.sh \$ADDON\n"

ADDONS=`ls -d */ | cut -d/ -f 1`
for ADDON in $ADDONS; do
   ADDON_DIR="${PWD}/${ADDON}"
   if [[ -f "${ADDON_DIR}/config.json" ]]; then 
      CONFIG="config.json"
   else
      CONFIG="config-hidden.json"
   fi

   BADGES=""
   if [[ -f "${ADDON_DIR}/${CONFIG}" ]]; then 
      ARCHS=$(jq -r '.arch // ["aarch64", "amd64", "armhf", "armv7", "i386"] | [.[] | .] | sort | join(" ")' ${ADDON_DIR}/${CONFIG})
      DONE_ENV="$DONE_ENV${DONE_PART/\$ENV/ADDON=\"$ADDON\" ARCHS=\"$ARCHS\" CONFIG=\"$CONFIG\" ${EXTRA_ENV}}"
      for ARCH in $ARCHS; do
         BUILD_ENV="$BUILD_ENV${BUILD_PART/\$ENV/ADDON=\"$ADDON\" ARCH=\"$ARCH\" CONFIG=\"$CONFIG\" ${EXTRA_ENV}}"
	 LABEL="$ARCH"
         BADGE_URL="https://badges.herokuapp.com/travis/Taapie/hassio-addons?branch=${BRANCH}&label=${LABEL}&env=ADDON=%22${ADDON}%22%20ARCH=%22${ARCH}%22"
	 BADGE_MD="[![Build Status]($BADGE_URL)](https://travis-ci.org/Taapie/hassio-addons)"
         BADGES="${BADGES} ${BADGE_MD}"
      done

      sed -i -e "/<!-- START_GEN_BADGES -->/,/<!-- END_GEN_BADGES -->/c\<!-- START_GEN_BADGES -->\n$BADGES\n<!-- END_GEN_BADGES -->" $ADDON_DIR/README.md
      git add $ADDON_DIR/README.md
   fi
done

sed -i -e "/#START_GEN_BUILD/,/#END_GEN_BUILD/c\#START_GEN_BUILD\n$BUILD_ENV#END_GEN_BUILD" $PWD/.travis.yml
sed -i -e "/#START_GEN_DONE/,/#END_GEN_DONE/c\#START_GEN_DONE\n$DONE_ENV#END_GEN_DONE" $PWD/.travis.yml

git add $PWD/.travis.yml
