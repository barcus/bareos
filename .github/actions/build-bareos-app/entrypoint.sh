#!/bin/sh -l
#export BUILDX_VER=v0.3.1
apk add curl
mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

ls -l ~/.docker/
docker version
export DOCKER_CLI_EXPERIMENTAL="enabled"
docker version
#docker context create ${bareos_app}
#docker buildx create ${bareos_app} --use
#docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
#docker buildx create --name builder --driver docker-container --use
#docker buildx inspect --bootstrap

docker buildx --help
#
echo " app : $bareos_app"
#
#while read app version arch app_path ; do
#  if [ "$app" == "$bareos_app" ] ; then
#    docker buildx build \
#      --platform ${arch} \
#      --output 'type=docker,push-false' \
#      --tag barcus/bareos-${app}:${version} \
#      ${app_path}
#  fi
#done < /github/workspace/homework/app_build.txt
