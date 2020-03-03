#!/usr/bin/env bash

#docker buildx create --name builder --driver docker-container --use

#
#while read app version arch app_path ; do
#  #if [ "$app" == "$INPUT_BAREOS_APP" ] ; then
#    env
#    tag="${version}"
#    re='^[0-9]+-alpine.*$'
#    if [[ $version =~ $re ]] ; then
#      tag="${version}-${arch}"
#    fi
#
#    # Build with buildx
#    docker buildx build \
#      --platform ${arch} \
#      #--output 'type=docker' \
#      --output "type=tar,dest=${workdir}/bareos-${app}-${tag}"
#      --tag barcus/bareos-${app}:${tag} \
#      ${app_path}
#
#    # Save image to file
#    #docker save \
#    #  --output ${workdir}/bareos-${app}-${tag}.tar \
#    #  barcus/bareos-${app}:${tag}
#  #fi
#done < ${workdir}/app_build.txt
#
#chmod 755 ${workdir}/bareos-*.tar
#ls -l  ${workdir}/


workdir="${GITHUB_WORKSPACE}/build-artifact"
docker_files=$(find ${workdir}/ -name "bareos-*.tar" 2>/dev/null)

for file in $docker_files; do

  docker load --input $file
  #app=$(echo $file| sed -n 's#^\([a-z]*\).*#\1#p')
  #app_dir=$(echo $file |cut -d'/' -f1)
  #version_dir=$(echo $file |cut -d'/' -f2)
  #version=$(echo $version_dir |cut -d'-' -f1)
  #base_img=$(echo $version_dir |cut -d'-' -f2)

  ## Define default tag for each Dockerfile
  #tag_build="${version}-${base_img}"
  #if [ "${app}" == 'director' ]; then
  #  backend=$(echo $app_dir |cut -d'-' -f2)
  #  tag_build="${tag_build}-${backend}"
  #fi

  ## Declare each Dockerfile with its tags for building
  #if [ "$version" == '18' ]; then
  #  if [ "${base_img}" == 'alpine' ]; then
  #    echo "${app} ${tag_build} amd64 ${app_dir}/${version_dir}" >> $build_file
  #    echo "${app} ${tag_build} arm64 ${app_dir}/${version_dir}" >> $build_file
  #  fi
  #fi
done
