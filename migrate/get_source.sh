#!/bin/bash

source_path=$1
target_path=$2

if [ -z "$source_path" ]
then
  exit 100
fi

# Check source type
# - GIT
# - directory
# - file

# extract the protocol
proto="$(echo $source_path | grep :// | sed -e's,^\(.*://\).*,\1,g')"
# remove the protocol
url="$(echo ${source_path/$proto/})"
# extract the host
host="$(echo $url | cut -d/ -f1)"
# extract the path (if any)
fullpath="/$(echo $url | grep / | cut -d/ -f2-)"
path=`dirname $fullpath`
file=`basename $fullpath`

if [ -z "$proto" ]
then
  if [[ $file == *.* ]]
  then
    type="FILE"
    cd $target_path
    mkdir target
    cd target
    cp $fullpath $file
    tgtfile=$file
    file="target"
    # unzip for war/jar/zip/ear
    # untar for tar/tar.gz/tgz
    if [[ "$tgtfile" =~ \.(war|jar|ear|zip)$ ]]; then
      unzip $tgtfile
    elif [[ "$tgtfile" =~ \.(tar|tar.gz|tgz)$ ]]; then
      tar -xf $tgtfile
    fi
  else
    type="PATH"
    cd $target_path
    cp -R $fullpath $file
  fi
else
  type="GIT"
  cd $target_path
  git clone $source_path
fi

if [[ $? -gt "0" ]]; then
  echo "Retrieve failed"
  exit 200
fi

if [[ "$type" =~ (GIT|PATH)$ ]]; then
  # find manifest.yml as the starting point for conversion
  manpath=`find $file -name manifest.yml`
  numman=`find $file -name manifest.yml | wc -l`
  if [[ $numman -ne 1 ]]; then
    echo "Cannot process multiple manifest git repo - manually clone the repo and choose the appropriate path"
    exit 170
  fi
  mandir=`dirname ${manpath}`
  if [[ ! $mandir == $file ]]; then
    mv ${mandir} .
    file=`basename ${mandir}`
  fi
  # if found pom.xml or gradle.properties do a build
  cd $file
  if [[ -f "pom.xml" ]]; then
    buildOut=`mvn clean install 2>&1`
  elif [[ -f "gradle.properties" ]]; then
    buildOut=`gradle build 2>1`
  fi
  if [[ $? -gt "0" ]];  then
    echo $buildOut
    exit 180
  fi
  manpath=`find . -name manifest.yml`
  tgtpath=`cat $manpath | grep "path:" | awk -F'path:' '{ print $NF }' | xargs`
  if [[ ! -z "$tgtpath" ]]; then
    file=${file}/${tgtpath}
  fi
fi
echo $file 

exit 0
