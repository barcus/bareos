#!/usr/bin/env bash

# Create build and use it for building
docker buildx create --name builder --driver docker-container --use
workdir="${GITHUB_WORKSPACE}/build"

while read app version arch app_path ; do
  tag="${version}"
  re='^[0-9]+-alpine.*$'
  if [[ $version =~ $re ]] ; then
    tag="${version}-${arch}"
  fi

  # Build with buildx
  docker buildx build \
    --platform ${arch} \
    --output 'type=docker,push=false' \
    --tag barcus/bareos-${app}:${tag} \
    ${app_path}

  # Save image to file
  docker save \
    --output ${workdir}/bareos-${app}-${tag}.tar \
    barcus/bareos-${app}:${tag}
done < ${workdir}/app_build.txt

chmod 755 ${workdir}/bareos-*.tar
