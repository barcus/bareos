#!/usr/bin/env bash
export BUILDX_VER=v0.3.1
export DOCKER_CLI_EXPERIMENTAL="enabled"

# Install Buildx plugin
mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx

# Run qemu
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Create build and use it for building
docker buildx create --name builder --driver docker-container --use
#docker buildx inspect --bootstrap
workdir="${GITHUB_WORKSPACE}"
while read app version arch app_path ; do
  if [ "$app" == "$INPUT_BAREOS_APP" ] ; then
    if [[ $version =~ ^18.* ]] ; then
    docker buildx build \
      --platform ${arch} \
      --output 'type=docker' \
      --tag barcus/bareos-${app}:${version}-${arch} \
      ${app_path}
    docker save \
      --output ${workdir}/bareos-${app}-${version}-${arch}.tar \
      barcus/bareos-${app}:${version}-${arch}
    fi
  fi
done < /github/workspace/homework/app_build.txt
ls -l ${workdir}/
