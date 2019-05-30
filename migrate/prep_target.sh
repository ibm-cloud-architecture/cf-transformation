#!/bin/bash

target_path=$1

if [ -z "$target_path" ]
then
  exit 999
fi

if [[ $target_path == /* ]]
then
  if [ ! -d $target_path ]
  then
    mkdir $target_path
  else
    cd $target_path
    rm -rf *
  fi
  if [ ! -d $target_path ]
  then
    exit 200
  fi
  exit 0
else
  exit 100
fi
