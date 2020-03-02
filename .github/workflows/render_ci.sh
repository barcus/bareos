#!/usr/bin/env bash

for app in storage webui director client ; do 
  sed "s#__BAREOS_APP__#$app#" bareos-app.tmpl > ${app}.yml
done
