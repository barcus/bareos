#!/usr/bin/env bash

workdir="${GITHUB_WORKSPACE}/build-artifact"
docker_files=$(find ${workdir}/ -name "bareos-*.tar" 2>/dev/null)

for file in $docker_files; do
  docker load --input $file
done

docker login -u barcus -p ${INPUT_DOCKER_PASS}

# Push images
while read app version arch app_path ; do
  build_tag=${version}

  re='^[0-9]+-alpine.*$'
  if [[ $version =~ $re ]] ; then
    build_tag="${version}-${arch}"
    manifest=1
  fi

  docker push barcus/bareos-${app}:${build_tag}
  while read app s_tag t_tag ; do
    if [ "${s_tag}" == ${build_tag} ]; then
      docker tag barcus/bareos-${app}:${s_tag} barcus/bareos-${app}:${t_tag}
      docker push barcus/bareos-${app}:${t_tag}
      tag_list="${tag_list} barcus/bareos-${app}:${t_tag}"
    fi
  done < ${workdir}/tag_build.txt

  # Create manifest if required
  if [ $manifest == 1 ]; then
    docker manifest create barcus/bareos-${app}:${build_tag} ${tag_list}
    docker manifest inspect barcus/bareos-${app}:${build_tag}
    docker manifest push barcus/bareos-${app}:${build_tag}
  fi
done < ${workdir}/app_build.txt
