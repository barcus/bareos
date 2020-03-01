#!/usr/bin/env bash

latest_ubuntu='19'
latest_alpine='18'
build_file="${GITHUB_WORKSPACE}/build/app_build.txt"
docker_files=$(find . -name Dockerfile 2>/dev/null)

echo $docker_files

for file in $docker_files; do
  app=$(echo $file| sed -n 's#^\./\([a-z]*\).*#\1#p')
  app_dir=$(echo $file |cut -d'/' -f2)
  version_dir=$(echo $file |cut -d'/' -f3)
  version=$(echo $version_dir |cut -d'-' -f1)
  base_img=$(echo $version_dir |cut -d'-' -f2)

  # Define default tag for each Dockerfile
  tag_build="${version}-${base_img}"
  if [ "${app}" == 'director' ]; then
    backend=$(echo $app_dir |cut -d'-' -f2)
    tag_build="${tag_build}-${backend}"
  fi

  # Declare each Dockerfile with its tags for building
  if [ "${base_img}" == 'ubuntu' ]; then
    echo "${app} ${tag_build} amd64 ${app_dir}/${version_dir}" >> $build_file
  fi
  if [ "${base_img}" == 'alpine' ]; then
    echo "${app} ${tag_build} amd64 ${app_dir}/${version_dir}" >> $build_file
    echo "${app} ${tag_build} arm64 ${app_dir}/${version_dir}" >> $build_file
  fi
done
