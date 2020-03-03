#!/usr/bin/env bash

export DOCKER_CLI_EXPERIMENTAL="enabled"
workdir="${GITHUB_WORKSPACE}/build-artifact"
docker_files=$(find ${workdir}/ -name "bareos-*.tar" 2>/dev/null)

for file in $docker_files; do
  docker load --input $file
done

docker login -u barcus -p ${INPUT_DOCKER_PASS}

# Push images
while read app version arch app_path ; do
  echo "on traite le tag build : $app $version $arch $app_path"
  build_tag=${version}
  is_alpine=0
  re='^[0-9]+-alpine.*$'
  if [[ $version =~ $re ]] ; then
    build_tag="${version}-${arch}"
    is_alpine=1
  fi

  # Push build_tag
  docker push barcus/bareos-${app}:${build_tag}

  while read build_app s_tag t_tag ; do
    echo "on traite le tag : $build_app $s_tag $t_tag"
    if [ $is_alpine == 0 ]; then
      docker tag barcus/bareos-${build_app}:${s_tag} barcus/bareos-${build_app}:${t_tag}
      docker push barcus/bareos-${build_app}:${t_tag}
    fi

    if [ $is_alpine == 1 ]; then
      echo "on cree la manifest : barcus/bareos-${build_app}:${t_tag} avec les tags : bareos-${build_app}:${s_tag}-amd64 et bareos-${build_app}:${s_tag}-arm64"
      docker manifest create barcus/bareos-${build_app}:${t_tag} \
        barcus/bareos-${build_app}:${s_tag}-amd64 \
        barcus/bareos-${build_app}:${s_tag}-arm64
      docker manifest inspect barcus/bareos-${build_app}:${t_tag}
      echo "on push le manifest barcus/bareos-${build_app}:${t_tag}"
      docker manifest push barcus/bareos-${build_app}:${t_tag}
    fi
  done < ${workdir}/tag_build.txt
done < ${workdir}/app_build.txt
