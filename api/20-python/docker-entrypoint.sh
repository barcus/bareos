#!/usr/bin/env sh

github_bareos='raw.githubusercontent.com/bareos/bareos'
rest_api_dir='master/rest-api'
filelist='bareos-restapi.py bareosRestapiModels.py metatags.yaml openapi.json requirements.txt'
dst='/opt'
secret=`tr -cd "[:alnum:]" < /dev/urandom | fold -w30 | head -n1`

# pull all files from https://github.com/bareos/bareos/tree/master/rest-api
for file in ${filelist}
do
  if [ ! -f "${dst}/${file}" ]
  then
    if [ -f /usr/bin/curl ]
    then
      curl --silent --insecure "https://${github_bareos}/${rest_api_dir}/${file}" \
        --output "${dst}/${file}"
    elif [ -f /usr/bin/wget ]
    then
      wget -q --output-document="${dst}/${file}" "https://${github_bareos}/${rest_api_dir}/${file}"
    fi
  fi
done

# Generate api.ini config
cat <<EOF > ${dst}/api.ini
[Director]
Name=${BAREOS_DIR_HOST}
Address=${BAREOS_DIR_HOST}
Port=9101

[JWT]
secret_key = ${secret}
algorithm = HS256
access_token_expire_minutes = 30

EOF

# update to new requirements on each container start
pip3 -qq --no-cache-dir install --upgrade -r ${dst}/requirements.txt

# Run Dockerfile CMD
exec "$@"
