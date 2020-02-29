#!/usr/bin/env bash
latest_ubuntu='19'
latest_alpine='18'
tag=${CIRCLE_TAG}
branch=${CIRCLE_BRANCH}

# define $release if it exists
release=''
re='^[0-9]+.*$'
if [[ ${branch} =~ $re ]]; then
  release=$(echo ${branch} |sed 's#^\([0-9]*\).*$#\1#')
fi
if [[ -n ${tag} ]]; then
  release=$(echo ${tag} |sed 's#^v\([0-9]*\)-.*$#\1#')
fi

# if $release is empty, build everything
docker_files=$(find ${BAREOS_APP}*/${release}* -name Dockerfile 2>/dev/null)

# define build args and connect to Docker Hub if required
build_args='build'
#if [ ${DEPLOY} ]; then
#  build_args='build --push'
#  docker login -u $DOCKER_USER -p $DOCKER_PASS
#fi

for file in $docker_files; do
  app_dir=$(echo $file |cut -d'/' -f1)
  version_dir=$(echo $file |cut -d'/' -f2)
  version=$(echo $version_dir |cut -d'-' -f1)
  base_img=$(echo $version_dir |cut -d'-' -f2)

  # define default tag build
  tag_build="${version}-${base_img}"
  if [ "${BAREOS_APP}" == 'director' ]; then
    backend=$(echo $app_dir |cut -d'-' -f2)
    tag_build="${tag_build}-${backend}"
  fi

  # create build file
  if [ "${base_img}" == 'ubuntu' ] ; then
    echo "${BAREOS_APP} ${tag_build} amd64 ${app_dir}/${version_dir}" >> file.build

    if [ "${backend}" != 'pgsql' ]; then
      echo "${BAREOS_APP} ${version} amd64 ${app_dir}/${version_dir}" >> file.build
    fi

    if [ "${version}" == "$latest_ubuntu" ]; then
      echo "${BAREOS_APP} ubuntu amd64 ${app_dir}/${version_dir}" >> file.build
      echo "${BAREOS_APP} latest amd64 ${app_dir}/${version_dir}" >> file.build
    fi
    if [ "${BAREOS_APP}" == 'director' ]; then
      echo "${BAREOS_APP} ${version}-ubuntu amd64 ${app_dir}/${version_dir}" >> file.build
    fi
  fi
  if [ "${base_img}" == 'alpine' ]; then
    echo "${BAREOS_APP} ${tag_build} amd64 ${app_dir}/${version_dir}" >> file.build
    echo "${BAREOS_APP} ${tag_build} arm64 ${app_dir}/${version_dir}" >> file.build
    echo "${BAREOS_APP} ${tag_build} arm ${app_dir}/${version_dir}" >> file.build

    if [ "${BAREOS_APP}" == "director" ]; then
      echo "${BAREOS_APP} ${version}-alpine amd64 ${app_dir}/${version_dir}" >> file.build
      echo "${BAREOS_APP} ${version}-alpine arm64 ${app_dir}/${version_dir}" >> file.build
      echo "${BAREOS_APP} ${version}-alpine arm ${app_dir}/${version_dir}" >> file.build
    fi
    if [ "${version}" == "$latest_alpine" ]; then
      echo "${BAREOS_APP} alpine amd64 ${app_dir}/${version_dir}" >> file.build
      echo "${BAREOS_APP} alpine arm64 ${app_dir}/${version_dir}" >> file.build
      echo "${BAREOS_APP} alpine arm ${app_dir}/${version_dir}" >> file.build
    fi
  fi
done
