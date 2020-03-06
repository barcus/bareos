#!/usr/bin/env bash

workdir="${GITHUB_WORKSPACE}/build"

# Load buildx binary
export DOCKER_CLI_EXPERIMENTAL="enabled"
mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
cp ${workdir}/docker-buildx ~/.docker/cli-plugins/

# Run qemu
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Create build context and build
docker buildx create --name builder --driver docker-container --use

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

  # Save image to tar file
  docker save \
    --output ${workdir}/bareos-${app}-${tag}.tar \
    barcus/bareos-${app}:${tag}
done < ${workdir}/app_build.txt

chmod 755 ${workdir}/bareos-*.tar

#EOF
