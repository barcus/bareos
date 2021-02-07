#!/usr/bin/env bash
set -x

workdir="${GITHUB_WORKSPACE}/build"
docker_files=$(find "${workdir}/" -name "bareos-*.tar" 2>/dev/null)

# Load Dockerfiles
echo ::group::Load Dockerfile
echo ${docker_files}
for file in $docker_files; do
  docker load --input "$file"
done
echo ::endgroup::

# Avoid DB check for director
touch /tmp/bareos-db.control

# Test images
echo ::group::Test build tags
while read app version arch app_path ; do
  DOCKER_ARGS=''
  build_tag=${version}
  re='^[0-9]+-alpine.*$'
  if [[ $version =~ $re ]] ; then
    build_tag="${version}-${arch}"
  fi

  # Test build tags
  if [[ "$app" == "director" ]] ; then
    DOCKER_ARGS="-v /tmp/bareos-db.control:/etc/bareos/bareos-db.control"
  fi
  if [[ $version =~ ^[0-9]+-ubuntu.*$ ]] ; then
    CMD="dpkg-query --showformat='${Version}' --show bareos-${app}" 
  fi
  if [[ $version =~ ^[0-9]+-alpine.*$ ]] ; then
    CMD="apk list --installed |egrep 'bareos-(webui-)?\d+'" 
  fi

  check_version=$(docker run --rm ${DOCKER_ARGS} \
    ${GITHUB_REPOSITORY}-${app}:${build_tag} \
    ${CMD} 2>/dev/null |tail -1)

  if [[ $version =~ ^[0-9]+-alpine.*$ ]] ; then
    check_version=$(echo $check_version |sed -n 's#[a-z-]*\(.*\)#\1#p')
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
