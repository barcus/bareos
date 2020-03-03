#!/usr/bin/env bash

workdir="${GITHUB_WORKSPACE}/build-artifact"
docker_files=$(find ${workdir}/ -name "bareos-*.tar" 2>/dev/null)

for file in $docker_files; do
  docker load --input $file
done

while read app s_tag t_tag ; do
  docker tag barcus/bareos-${app}:${s_tag} barcus/bareos-${app}:${t_tag}
done < ${workdir}/tag_build.txt

cat ${workdir}/tag_build.txt
cat ${workdir}/app_build.txt
