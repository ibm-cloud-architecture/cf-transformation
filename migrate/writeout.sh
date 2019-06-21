#!/bin/bash

TGTPATH=$1 
TGTTYPE=$4
APPLNAME=$2
APPLTYPE=$3


CODEDIR=$( dirname "${BASH_SOURCE[0]}" )
if [ $CODEDIR == "." ]; then
  CODEDIR=`pwd`
fi

# Read result.html and write out result.html 
IFS=$'\n'       # make newlines the only separator

files=$(cat $TGTPATH/genfiles.txt)

for line in $(cat $CODEDIR/result.html)    
do
  if [[ "$line" == ":genfiles." ]]; then
    echo $files
  else
    line=$(echo $line | sed -e "s/\:applname./$APPLNAME/g" | sed -e "s/\:appltype./$APPLTYPE/g" | sed -e "s,\:tgtdir.,$TGTPATH,g" | sed -e "s/\:tgttype./$TGTTYPE/g")
    echo "$line"
  fi
done > $TGTPATH/result.html
