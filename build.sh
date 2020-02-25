#!/usr/bin/env bash

latest_ubuntu='19'
latest_alpine='18'
tag=${CIRCLE_TAG}
branch=${CIRCLE_BRANCH}

release=''
re='^[0-9]+.*$'
if [[ ${branch} =~ $re ]]; then
  release=$(echo ${branch} |sed 's#^\([0-9]*\).*$#\1#')
fi
if [[ -n ${tag} ]]; then
  release=$(echo ${tag} |sed 's#^v\([0-9]*\)-.*$#\1#')
fi

# if $release is empty, build everything
docker_files=$(find ${BAREOS_APP}*/18-* -name Dockerfile 2>/dev/null)

docker login -u $DOCKER_USER -p $DOCKER_PASS
build_args='build'
[[ ${DEPLOY} == 'yes' ]] && build_args='build --push'

for file in $docker_files; do
  app_dir=$(echo $file |cut -d'/' -f1)
  version_dir=$(echo $file |cut -d'/' -f2)
  version=$(echo $version_dir |cut -d'-' -f1)
  base_img=$(echo $version_dir |cut -d'-' -f2)
  tag_build="${version}-${base_img}"
  if [ "${BAREOS_APP}" == 'director' ]; then
    backend=$(echo $app_dir |cut -d'-' -f2)
    tag_build="${tag_build}-${backend}"
  fi

  build_arch='linux/amd64'
  [ "${base_img}" == "alpine" ] && build_arch='linux/amd64,linux/arm64/v8'

  docker context create ${BAREOS_APP}-${tag_build} --description "this is the new $BAREOS_APP image"
  docker buildx create ${BAREOS_APP}-${tag_build} --use
  docker buildx $build_cmd --platform "$build_arch" \
    -t barcus/bareos-${BAREOS_APP}-new:${tag_build} ${app_dir}/${version_dir}

  if [ "${base_img}" == 'ubuntu' ] && [ "${backend}" != 'pgsql' ]; then
    docker buildx $build_args --platform "$build_arch" \
      -t barcus/bareos-${BAREOS_APP}-new:${version} ${app_dir}/${version_dir}
    if [ "${version}" == "$latest_ubuntu" ]; then
      docker buildx $build_args --platform "$build_arch" \
        -t barcus/bareos-${BAREOS_APP}-new:ubuntu ${app_dir}/${version_dir}
      docker buildx $build_args --platform "$build_arch" \
        -t barcus/bareos-${BAREOS_APP}-new:latest ${app_dir}/${version_dir}
    fi
    if [ "${BAREOS_APP}" == 'director' ]; then
      docker buildx $build_args --platform "$build_arch" \
        -t barcus/bareos-${BAREOS_APP}-new:${version}-ubuntu ${app_dir}/${version_dir}
    fi
  fi
  if [ "${base_img}" == 'alpine' ] && [ "${version}" == "$latest_alpine" ]; then
    docker buildx $build_args --platform "$build_arch" \
      -t barcus/bareos-${BAREOS_APP}-new:alpine ${app_dir}/${version_dir}
  fi
done
