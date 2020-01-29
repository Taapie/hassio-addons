#!/usr/bin/env bash
set -e

BADGE_URL="https://badges.herokuapp.com/travis/Taapie/hassio-addons?branch=${BRANCH}&label=${LABEL}&env=ADDON=%22$ADDON%22%20ARCH=%22$ARCH%22"
BRANCH=`git branch --show-current`

ADDONS=`ls -d */ | cut -d/ -f 1`
for ADDON in $ADDONS; do
   if [[ $ADDON == "hello-world" ]]; then
      CONFIG="config-test.json"
   else
      CONFIG="config.json"
   fi

   BADGES=""
   if [[ -f "${ADDON}/${CONFIG}" ]]; then 
      ARCHS=$(jq -r '.arch // ["armv7", "armhf", "amd64", "aarch64", "i386"] | [.[] | .] | join(" ")' ${ADDON}/${CONFIG})
      for ARCH in $ARCHS; do
         ENV="$ENV  - ADDON=\"$ADDON\" ARCH=\"$ARCH\" CONFIG=\"$CONFIG\"\n"
	 LABEL="$ARCH"
         BADGE_URL="https://badges.herokuapp.com/travis/Taapie/hassio-addons?branch=${BRANCH}&label=${LABEL}&env=ADDON=%22${ADDON}%22%20ARCH=%22${ARCH}%22"
	 BADGE_MD="[![Build Status]($BADGE_URL)](https://travis-ci.org/Taapie/hassio-addons)"
         BADGES="$BADGE_MD\n$BADGES"
      done

      sed -i -e "/<!-- START_GEN_BADGES -->/,/<!-- END_GEN_BADGES -->/c\<!-- START_GEN_BADGES -->\n$BADGES<!-- END_GEN_BADGES -->" $ADDON/README.md
   fi
done

sed -i -e "/#START_GEN_ENV/,/#END_GEN_ENV/c\#START_GEN_ENV\n$ENV#END_GEN_ENV" .travis.yml
