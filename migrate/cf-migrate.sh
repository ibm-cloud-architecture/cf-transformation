#!/bin/bash

# Handle arguments
# Required:
# -s: conversion source (Whatever "cf push -p" uses
# Optional:
# -b: buildpack name (default: ibm-websphere-liberty)
# -t: Target (temp) directory (default: /tmp/convdir)
# . . . (wait for Dave, if he needs more options


while [[ "$#" -gt 0 ]]; do case $1 in
  -t) target_path="$2"; shift;;
  -b) buildpack="$2";shift;;
  -s) source_path="$2";shift;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z "$source_path" ]; then
  exit 999
fi

if [ -z "$buildpack" ]; then
  buildpack="ibm-websphere-liberty"
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

bpath=`$CODEDIR/get_buildpack.sh $buildpack $CONVDIR`

if [[ $? -gt 0 ]]; then
  echo "Cannot retrieve buildpack for ${buildpack}"
  echo "${bpath}"
  exit 20
fi

echo "Buildpack is retrieved into ${CONVDIR}/${bpath}"

#########################################
# Run the buildpack: 
# assume compile and release are needed
#########################################

cd ${CONVDIR}${tpath}
compileOut=`${CONVDIR}${bpath}/bin/compile ${CONVDIR}${tpath} /tmp 2>&1`
if [[ $? -gt 0 ]];then
  echo "Compile failed \n ${compileOut}"
  exit 30
else
  echo "Compile finished \n ${compileOut}"
fi

releaseOut=`${CONVDIR}${bpath}/bin/release ${CONVDIR}${tpath} 2>&1`
if [[ $? -gt 0 ]];then
  echo "Release failed \n ${releaseOut}"
  exit 40
else
  echo "Release finished \n ${releaseOut}"
fi

#########################################
# Assume conversion is successful
# Create docker file
#########################################

$CODEDIR/create_dockerfile.sh $CONVDIR

if [[ $? -gt 0 ]]; then
  echo "Dockerfile creation failed"
  exit 40
fi

$CODEDIR/create_yaml.sh $CONVDIR

if [[ $? -gt 0 ]]; then
  echo "Yaml file creation failed"
  exit 50
fi

#########################################
# finalize output
#########################################

echo "Output file structure is: "
tree $CONVDIR
echo "\n\nConversion is done, you can deploy application using the following commands"
echo " ... "

exit 0
