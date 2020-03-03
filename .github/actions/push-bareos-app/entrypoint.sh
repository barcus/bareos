#!/usr/bin/env bash

#docker buildx create --name builder --driver docker-container --use
workdir="${GITHUB_WORKSPACE}"
#
#while read app version arch app_path ; do
#  #if [ "$app" == "$INPUT_BAREOS_APP" ] ; then
#    env
#    tag="${version}"
#    re='^[0-9]+-alpine.*$'
#    if [[ $version =~ $re ]] ; then
#      tag="${version}-${arch}"
#    fi
#
#    # Build with buildx
#    docker buildx build \
#      --platform ${arch} \
#      #--output 'type=docker' \
#      --output "type=tar,dest=${workdir}/bareos-${app}-${tag}"
#      --tag barcus/bareos-${app}:${tag} \
#      ${app_path}
#
#    # Save image to file
#    #docker save \
#    #  --output ${workdir}/bareos-${app}-${tag}.tar \
#    #  barcus/bareos-${app}:${tag}
#  #fi
#done < ${workdir}/app_build.txt
#
#chmod 755 ${workdir}/bareos-*.tar
#ls -l  ${workdir}/

ls -l ${workdir}/
