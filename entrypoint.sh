#!/bin/sh

if [ "${1}" = "start" ]; then
  exec bash -c "/opt/phabricator/bin/phd start; source /etc/apache2/envvars; /usr/sbin/apache2 -DFOREGROUND"
else
  exec $@
fi
