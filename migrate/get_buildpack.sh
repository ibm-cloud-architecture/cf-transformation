#!/bin/bash

buildpack=$1
target_path=$2

CODEDIR=$( dirname "${BASH_SOURCE[0]}" )
if [ $CODEDIR == "." ]; then
  CODEDIR=`pwd`
fi

if [ -z "$buildpack" ]
then
  exit 100
fi

bprepo="${buildpack}-buildpack"
bpgit="https://github.com/cloudfoundry/${buildpack}-buildpack"

# check if repo exists 

curl -f $bpgit > /dev/null 2>&1

if [ $? -gt 0 ]
then
  exit 10
fi

cd $target_path
git clone $bpgit

if [ $? -gt 0 ]
then
  echo "Clone failed"
  exit 20
fi

if [[ $buildpack == "ibm-websphere-liberty" ]] 
then
  cp $CODEDIR/licenses.yml $target_path/$bprepo/config/licenses.yml
fi

echo "${bprepo}"

exit 0
