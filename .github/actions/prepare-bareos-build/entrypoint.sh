#!/usr/bin/env bash

export DOCKER_CLI_EXPERIMENTAL="enabled"
BUILDX_VER='v0.3.1'
latest_ubuntu='19'
latest_alpine='18'

build_file="${GITHUB_WORKSPACE}/build/app_build.txt"
build_app="$INPUT_BAREOS_APP"
docker_files=$(find ${build_app}*/ -name Dockerfile 2>/dev/null)

for file in $docker_files; do
  app=$(echo $file| sed -n 's#^\([a-z]*\).*#\1#p')
  app_dir=$(echo $file |cut -d'/' -f1)
  version_dir=$(echo $file |cut -d'/' -f2)
  version=$(echo $version_dir |cut -d'-' -f1)
  base_img=$(echo $version_dir |cut -d'-' -f2)

  # Define default tag for each Dockerfile
  tag_build="${version}-${base_img}"
  if [ "${app}" == 'director' ]; then
    backend=$(echo $app_dir |cut -d'-' -f2)
    tag_build="${tag_build}-${backend}"
  fi

  # Declare each Dockerfile with its tags for building
  if [ "$version" == '18' ]; then
    #echo "${app} ${tag_build} amd64 ${app_dir}/${version_dir}" >> $build_file
    if [ "${base_img}" == 'alpine' ]; then
      echo "${app} ${tag_build} arm64 ${app_dir}/${version_dir}" >> $build_file
    fi
  fi
done

# Install Buildx plugin
mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx

# Run qemu
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
