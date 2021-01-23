#!/usr/bin/env bash

BUILDX_VER='v0.3.1'
latest_ubuntu='20'
latest_alpine='20'

build_file="${GITHUB_WORKSPACE}/build/app_build.txt"
tag_file="${GITHUB_WORKSPACE}/build/tag_build.txt"
build_app="$INPUT_BAREOS_APP"
docker_files=$(find ${build_app}*/ -name Dockerfile 2>/dev/null)

mkdir -p "${GITHUB_WORKSPACE}/build"

for file in $docker_files; do
  backend=''
  default_backend='mysql'
  app=$(echo "$file"| sed -n 's#^\([a-z]*\).*#\1#p')
  app_dir=$(echo "$file" |cut -d'/' -f1)
  version_dir=$(echo "$file" |cut -d'/' -f2)
  version=$(echo "$version_dir" |cut -d'-' -f1)
  base_img=$(echo "$version_dir" |cut -d'-' -f2)
  [[ $version -ge 20 ]] && default_backend='pgsql'

  # Define default tag
  tag_build="${version}-${base_img}"
  if [ "${app}" == 'director' ]; then
    backend=$(echo "$app_dir" |cut -d'-' -f2)
    tag_build="${tag_build}-${backend}"
  fi

  # Declare each Dockerfile and tags related
  if [ "${base_img}" == 'ubuntu' ]; then
    echo "${app} ${tag_build} amd64 ${app_dir}/${version_dir}" >> "$build_file"

    if [ "${app}" == 'director' ] && [ "${backend}" == "${default_backend}" ]; then
      echo "${app} ${tag_build} ${version}-ubuntu" >> "$tag_file"
      echo "${app} ${tag_build} ${version}" >> "$tag_file"
      if [ "${version}" == "$latest_ubuntu" ]; then
        echo "${app} ${tag_build} ubuntu" >> "$tag_file"
        echo "${app} ${tag_build} latest" >> "$tag_file"
      fi
    fi
    if [ "${app}" != 'director' ]; then
      echo "${app} ${tag_build} ${version}" >> "$tag_file"
      if [ "${version}" == "$latest_ubuntu" ]; then
        echo "${app} ${tag_build} ubuntu" >> "$tag_file"
        echo "${app} ${tag_build} latest" >> "$tag_file"
      fi
    fi
  fi

  if [ "${base_img}" == 'alpine' ]; then
    echo "${app} ${tag_build} amd64 ${app_dir}/${version_dir}" >> "$build_file"
    echo "${app} ${tag_build} arm64 ${app_dir}/${version_dir}" >> "$build_file"
    echo "${app} ${tag_build} ${tag_build}" >> "$tag_file"

    if [ "${app}" == 'director' ] && [ "${backend}" == "${default_backend}" ]; then
      echo "${app} ${tag_build} ${version}-alpine" >> "$tag_file"
      if [ "${version}" == "$latest_alpine" ]; then
        echo "${app} ${tag_build} alpine" >> "$tag_file"
      fi
    fi
    if [ "${app}" != 'director' ] && [ "${version}" == "$latest_alpine" ]; then
      echo "${app} ${tag_build} alpine" >> "$tag_file"
    fi
  fi
done

# Download Docker Buildx plugin
buildx_url="https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64"
curl --silent -L "${buildx_url}" > "${GITHUB_WORKSPACE}/build/docker-buildx"

#EOF
