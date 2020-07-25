#!/usr/bin/env bash

workdir="${GITHUB_WORKSPACE}/build"
docker_files=$(find "${workdir}/" -name "bareos-*.tar" 2>/dev/null)

# Enable experimental feature in Docker
export DOCKER_CLI_EXPERIMENTAL="enabled"

# Load Dockerfiles
for file in $docker_files; do
  docker load --input "$file"
done

# Connect Docker Hub
docker login -u 'barcus' -p "${INPUT_DOCKER_PASS}"

# Push images and manifests
while read app version arch app_path ; do
  build_tag=${version}
  re='^[0-9]+-alpine.*$'
  if [[ $version =~ $re ]] ; then
    build_tag="${version}-${arch}"
    rm_tag="$rm_tag ${GITHUB_REPOSITORY}-${app}:${build_tag}"
  fi
  # Push build_tag
  docker push "${GITHUB_REPOSITORY}-${app}:${build_tag}"
done < "${workdir}/app_build.txt"

while read build_app s_tag t_tag ; do
  # Add and push tag for Ubuntu 
  if [[ $s_tag =~ ^[0-9]+-ubuntu.*$ ]]; then
    docker tag "${GITHUB_REPOSITORY}-${build_app}:${s_tag}" \
      "${GITHUB_REPOSITORY}-${build_app}:${t_tag}"
    docker push "${GITHUB_REPOSITORY}-${build_app}:${t_tag}"
  fi
  # Create and push manifest for Alpuine (arm64 + amd64)
  if [[ $s_tag =~ ^[0-9]+-alpine.*$ ]]; then
    docker manifest create "${GITHUB_REPOSITORY}-${build_app}:${t_tag}" \
      "${GITHUB_REPOSITORY}-${build_app}:${s_tag}-amd64" \
      "${GITHUB_REPOSITORY}-${build_app}:${s_tag}-arm64"
    docker manifest push "${GITHUB_REPOSITORY}-${build_app}:${t_tag}"
  fi
done < "${workdir}/tag_build.txt"

# Clean Alpine build_tag by arch
docker run --rm lumir/remove-dockerhub-tag \
  --user "${GITHUB_ACTOR}" --password "${INPUT_DOCKER_PASS}" $rm_tag

#EOF
