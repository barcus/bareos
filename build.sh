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

mkdir -p images
docker login -u $DOCKER_USER -p $DOCKER_PASS

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

  build_arch='amd64'
  [ "${base_img}" == "alpine" ] && build_arch='linux/amd64,linux/arm64/v8'
  #if [ "${base_img}" == 'ubuntu' ] && [ "${backend}" != 'pgsql' ]; then
  #fi

  docker context create ${BAREOS_APP}-${tag_build} --description "this is the new $BAREOS_APP image"
  docker buildx create ${BAREOS_APP}-${tag_build} --use
  docker buildx build --load \
    --platform "$build_arch" \
    -t barcus/bareos-${BAREOS_APP}-new:${tag_build} ${app_dir}/${version_dir}
  #echo "${app_dir} ${release_dir} ${base_img} ${tag_build}" >> env/img_build
done
#mkdir env && touch env/img_build && touch env/img_tags
#for file in $(find ${BAREOS_APP}*/${release}-* -name Dockerfile); do
#  app_dir=$(echo $file |cut -d'/' -f1)
#  release_dir=$(echo $file |cut -d'/' -f2)
#  version=$(echo $release_dir |cut -d'-' -f1)
#  base_img=$(echo $release_dir |cut -d'-' -f2)
#  tag_build="${release_dir}"
#  if [ "${BAREOS_APP}" == 'director' ]; then
#    backend=$(echo $app_dir |cut -d'-' -f2)
#    tag_build="${release_dir}-${backend}"
#  fi
#  echo "${app_dir} ${release_dir} ${base_img} ${tag_build}" >> env/img_build
#  if [ "${base_img}" == 'ubuntu' ] && [ "${backend}" != 'pgsql' ]; then
#    echo "${tag_build} ${version}" >> env/img_tags
#    if [ "${version}" == "$latest_ubuntu" ]; then
#      echo "${tag_build} ubuntu" >> env/img_tags
#      echo "${tag_build} latest" >> env/img_tags
#    fi
#    if [ "${BAREOS_APP}" == 'director' ]; then
#      echo "${tag_build} ${version}-ubuntu" >> env/img_tags
#    fi
#  fi
#  if [ "${base_img}" == 'alpine' ] && [ "${version}" == "$latest_alpine" ]; then
#    echo "${tag_build} alpine" >> env/img_tags
#  fi
#done
#cat env/img_build env/img_tags
