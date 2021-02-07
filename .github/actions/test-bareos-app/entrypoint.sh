#!/usr/bin/env bash

workdir="${GITHUB_WORKSPACE}/build"
docker_files=$(find "${workdir}/" -name "bareos-*.tar" 2>/dev/null)

# Load Dockerfiles
echo ::group::Load Dockerfile
echo ${docker_files}
for file in $docker_files; do
  docker load --input "$file"
done
echo ::endgroup::

# Push tags and manfiests
echo ::group::Test build tags
while read app version arch app_path ; do
  build_tag=${version}
  re='^[0-9]+-alpine.*$'
  if [[ $version =~ $re ]] ; then
    build_tag="${version}-${arch}"
  fi

  # Test build tags
  if [[ "$app" == "director" ]] ; then
    touch /tmp/bareos-db.control
    check_version=$(docker run --rm \
      -v /tmp/bareos-db.control:/etc/bareos/bareos-db.control \
      ${GITHUB_REPOSITORY}-${app}:${build_tag} \
      dpkg-query --showformat='${Version}' --show bareos-${app} 2>/dev/null |tail -1)
  else
    check_version=$(docker run --rm \
      ${GITHUB_REPOSITORY}-${app}:${build_tag} \
      dpkg-query --showformat='${Version}' --show bareos-${app} 2>/dev/null |tail -1)
  fi
  short_version=$(echo $check_version |cut -d'.' -f1)

  if [[ $short_version -ne $version ]] ; then
    echo ::error:: ERROR: ${app}:${build_tag} is ${short_version}
  else
    echo "OK: ${app}:${build_tag} is ${short_version}"
  fi

done < "${workdir}/app_build.txt"
echo ::endgroup::

#EOF
