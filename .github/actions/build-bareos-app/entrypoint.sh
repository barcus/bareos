#!/bin/sh -l
#export BUILDX_VER=v0.3.1
#apt update && apt install curl docker-ce
#mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
#curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
#chmod a+x ~/.docker/cli-plugins/docker-buildx
#docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker version
mkdir ~/.docker
cat ~/.docker/config.json
cat ~/.docker/daemon.json

docker version
#docker context create ${bareos_app}
#docker buildx create ${bareos_app} --use

while read app version arch app_path ; do
  if [ "$app" = "$bareos_app" ] ; then
    docker buildx build \
      --platform ${arch} \
      --output 'type=docker,push-false' \
      --tag barcus/bareos-${app}:${version} \
      ${app_path}
  fi
done < /github/workspace/homework/app_build.txt
