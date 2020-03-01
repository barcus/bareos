#!/usr/bin/env bash

latest_ubuntu='19'
latest_alpine='18'
build_file='build/app_build.txt'
tag_file='build/app_tag.txt'

docker_files=$(find . -name Dockerfile 2>/dev/null)

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
  if [ "${base_img}" == 'ubuntu' ] ; then
    echo "${app} ${tag_build} amd64 ${app_dir}/${version_dir}" >> $build_file

    #if [ "${backend}" != 'pgsql' ]; then
    #  echo "${app} ${version} amd64 ${app_dir}/${version_dir}" >> $build_file
    #fi

    #if [ "${version}" == "$latest_ubuntu" ]; then
    #  echo "${app} ubuntu amd64 ${app_dir}/${version_dir}" >> $build_file
    #  echo "${app} latest amd64 ${app_dir}/${version_dir}" >> $build_file
    #fi
    #if [ "${app}" == 'director' ]; then
    #  echo "${app} ${version}-ubuntu amd64 ${app_dir}/${version_dir}" >> $build_file
    #fi
  fi
  if [ "${base_img}" == 'alpine' ]; then
    echo "${app} ${tag_build} amd64 ${app_dir}/${version_dir}" >> $build_file
    echo "${app} ${tag_build} arm64 ${app_dir}/${version_dir}" >> $build_file
    #echo "${app} ${tag_build} arm ${app_dir}/${version_dir}" >> $build_file

    #if [ "${app}" == "director" ]; then
    #  echo "${app} ${version}-alpine amd64 ${app_dir}/${version_dir}" >> $build_file
    #  echo "${app} ${version}-alpine arm64 ${app_dir}/${version_dir}" >> $build_file
    #  echo "${app} ${version}-alpine arm ${app_dir}/${version_dir}" >> $build_file
    #fi
    #if [ "${version}" == "$latest_alpine" ]; then
    #  echo "${app} alpine amd64 ${app_dir}/${version_dir}" >> $build_file
    #  echo "${app} alpine arm64 ${app_dir}/${version_dir}" >> $build_file
    #fi
  fi
done
