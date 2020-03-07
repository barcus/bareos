#!/usr/bin/env bash
set -x

docker version
# Update Docker Hub overview
docker run -v $PWD:/workspace \
  -e DOCKERHUB_USERNAME='barcus' \
  -e DOCKERHUB_PASSWORD='testcigithub' \
  -e DOCKERHUB_REPOSITORY="${GITHUB_REPOSITORY}-${INPUT_BAREOS_APP}" \
  -e README_FILEPATH='/workspace/README.md' \
  peterevans/dockerhub-description:2.1.0

#EOF
