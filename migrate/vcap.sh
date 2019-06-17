#!/bin/bash

# VCAP_SERVICES=`cat vcap.json`
# VCAP_SERVICES must be retrieved; if login to the IBM Cloud Public, you can use the following line:
if [[ -z $VCAP_SERVICES ]]; then
  echo "Skipping VCAP_SERVICES processing"
  exit 0
fi
TGTPATH=$1
vfile="${TGTPATH}/vcap.json"
echo $VCAP_SERVICES > ${vfile}

exit 0
