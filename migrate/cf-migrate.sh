#!/bin/bash

# Handle arguments
# Required:
# -s: conversion source (Whatever "cf push -p" uses
# Optional:
# -b: buildpack name (default: ibm-websphere-liberty)
# -t: Target (temp) directory (default: /tmp/convdir)
# -e: Target environment (default: openshift; option openshift, iks, icp)
# . . . (wait for Dave, if he needs more options


while [[ "$#" -gt 0 ]]; do case $1 in
  -t) target_path="$2"; shift;;
  -b) buildpack="$2";shift;;
  -s) source_path="$2";shift;;
  -e) target_env="$2";shift;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z "$source_path" ]; then
  exit 999
fi

if [ -z "$buildpack" ]; then
  buildpack="ibm-websphere-liberty"
fi

if [ -z "$target_env" ]; then
  target_env="openshift"
fi


# Migrate cf application

#########################################
# Create conversion directory 
#########################################

if [ -z "$target_path" ]; then
  CONVDIR=/tmp/convdir
else
  CONVDIR=$target_path
fi

CODEDIR=$( dirname "${BASH_SOURCE[0]}" )
if [ $CODEDIR == "." ]; then
  CODEDIR=`pwd`
fi
echo "Running command from" $CODEDIR

$CODEDIR/prep_target.sh $CONVDIR

if [[ $? -gt 0 ]]; then
  echo "Dir $CONVDIR creation failed"
  exit
fi

echo "Converting in $CONVDIR"

#########################################
# Collecting build artifact in convdir
#########################################

tpath=`$CODEDIR/get_source.sh $source_path $CONVDIR`

if [[ $? -gt 0 ]]; then
  echo "Cannot retrieve source from ${source_path}"
  echo "${tpath}"
  exit 10
fi

echo "The source is retrieved from ${source_path} into ${CONVDIR}/${tpath}"

#########################################
# Generate additional necessary files
#########################################

if [[ "$buildpack" == "ibm-websphere-liberty" ]]; then
  $CODEDIR/server_xml.sh $CONVDIR/${tpath}
  VCAP_SERVICES=$(cat vcap.json)
  export VCAP_SERVICES
  $CODEDIR/vcap.sh 

elif [[ "$buildpack" == "nodejs" ]]; then

elif [[ "$buildpack" == "" ]]; then

fi

#########################################
# Assume conversion is successful
# Create docker file
#########################################

app_name=`basename ${source_path}`

$CODEDIR/create_dockerfile.sh $CONVDIR/${tpath} ${buildpack}

if [[ $? -gt 0 ]]; then
  echo "Dockerfile creation failed"
  exit 40
fi

$CODEDIR/create_yaml.sh $CONVDIR/${tpath}

if [[ $? -gt 0 ]]; then
  echo "Yaml file creation failed"
  exit 50
fi

#########################################
# finalize output
#########################################

$CODEDIR/writeout.sh $CONVDIR/${app_name} ${app_name} ${buildpack} ${tgttype}

echo "Open the result file in: "
echo $CONVDIR/$app_name/result.html

exit 0
