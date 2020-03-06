#!/usr/bin/env bash

workflow_app=${INPUT_BAREOS_APP}
workdir="${GITHUB_WORKSPACE}/build"
docker_files=$(find ${workdir}/ -name "bareos-*.tar" 2>/dev/null)

# Enable experimental feature in Docker
export DOCKER_CLI_EXPERIMENTAL="enabled"

# Load Dockerfiles
for file in $docker_files; do
  docker load --input $file
done

# Connect Docker Hub
docker login -u barcus -p ${INPUT_DOCKER_PASS}

# Push images and manifests
while read app version arch app_path ; do
  build_tag=${version}
  re='^[0-9]+-alpine.*$'
  if [[ $version =~ $re ]] ; then
    build_tag="${version}-${arch}"
    rm_tag="$rm_tag barcus/bareos-${app}:${build_tag}"
  fi
  # Push build_tag
  docker push barcus/bareos-${app}:${build_tag}
done < ${workdir}/app_build.txt

while read build_app s_tag t_tag ; do
  # Add and push tag for Ubuntu 
  if [[ $s_tag =~ ^[0-9]+-ubuntu.*$ ]]; then
    docker tag barcus/bareos-${build_app}:${s_tag} barcus/bareos-${build_app}:${t_tag}
    docker push barcus/bareos-${build_app}:${t_tag}
  fi
  # Create and push manifest for Alpuine (arm64 + amd64)
  if [[ $s_tag =~ ^[0-9]+-alpine.*$ ]]; then
    docker manifest create barcus/bareos-${build_app}:${t_tag} \
      barcus/bareos-${build_app}:${s_tag}-amd64 \
      barcus/bareos-${build_app}:${s_tag}-arm64
    docker manifest push barcus/bareos-${build_app}:${t_tag}
  fi
done < ${workdir}/tag_build.txt

# Clean Alpine build_tag by arch
docker run --rm lumir/remove-dockerhub-tag \
  --user barcus --password ${INPUT_DOCKER_PASS} $rm_tag

# Update Dockr Hub overview
docker run -v $PWD:/workspace \
  -e DOCKERHUB_USERNAME='barcus' \
  -e DOCKERHUB_PASSWORD=$INPUT_DOCKER_PASS \
  -e DOCKERHUB_REPOSITORY="barcus/bareos-${workflow_app}" \
  -e README_FILEPATH='/workspace/README.md' \
  peterevans/dockerhub-description:2.1.0

#EOF
