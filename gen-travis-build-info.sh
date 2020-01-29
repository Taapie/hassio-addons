#!/usr/bin/env bash
set -e

ENV=""
ADDONS=`ls -d */ | cut -d/ -f 1`
for ADDON in $ADDONS; do
   if [[ $ADDON == "hello-world" ]]; then
      CONFIG="config-test.json"
   else
      CONFIG="config.json"
   fi

   if [[ -f "${ADDON}/${CONFIG}" ]]; then 
      ARCHS=$(jq -r '.arch // ["armv7", "armhf", "amd64", "aarch64", "i386"] | [.[] | .] | join(" ")' ${ADDON}/${CONFIG})
      for ARCH in $ARCHS; do
         ENV="$ENV  - ADDON=\"$ADDON\" ARCH=\"$ARCH\"\n"
      done
   fi
done

echo $ENV

sed -i -e "/#START_GEN_ENV/,/#END_GEN_ENV/c\#START_GEN_ENV\n$ENV#END_GEN_ENV" .travis.yml
