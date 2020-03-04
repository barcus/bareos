#!/usr/bin/env bash

# Create build and use it for building
docker buildx create --name builder --driver docker-container --use
workdir="${GITHUB_WORKSPACE}/build"

mkdir -p "$workdir"
while read app version arch app_path ; do
  tag="${version}"
  re='^[0-9]+-alpine.*$'

  if [[ $version =~ $re ]] ; then
    tag="${version}-${arch}"
  fi

  docker buildx build \
    --platform ${arch} \
    --output "type=tar,dest=${workdir}/bareos-${app}-${tag}.tar" \
    --tag barcus/bareos-${app}:${tag} \
    ${app_path}
done < ${workdir}/app_build.txt

chmod 755 ${workdir}/bareos-*.tar

#EOF
