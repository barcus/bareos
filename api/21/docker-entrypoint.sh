#!/usr/bin/env ash
#set -x

secret=`tr -cd "[:alnum:]" < /dev/urandom | fold -w30 | head -n1`

# Generate api.ini config
cat <<EOF > /home/bareos/api.ini
[Director]
Name=${BAREOS_DIR_HOST}
Address=${BAREOS_DIR_HOST}
Port=9101

[JWT]
secret_key = ${secret}
algorithm = HS256
access_token_expire_minutes = 30
EOF

# Run Dockerfile CMD
exec "$@"
