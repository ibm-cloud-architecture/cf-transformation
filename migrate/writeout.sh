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
  elif [[ "$line" == ":deployapp." ]]; then
    if [[ "$TGTTYPE" == "openshift" ]]; then
      echo "<LI>Login to OpenShift"
      echo "<XMP>oc login ${KUBESERVER}</XMP>"
      echo "<LI>Create application from the deploy template"
      echo "<XMP>oc new-app -f deploy-openshift/deploy-template.yaml -pTARGET_HOST=${REPOHOST} -pTARGET_WORKSPACE=${REPOSPACE}</XMP>"
    else
      if [[ "$TGTTYPE" == "iks" ]]; then
        echo "<LI>Login to IBM Cloud"
        echo "<XMP>ibmcloud login </XMP>"
        echo "<XMP>ibmcloud ks cluster-config ${IKSCLUSTER}</XMP>"
        echo "<XMP>export KUBECONFIG=<configfile></XMP>"
      elif [[ "$TGTTYPE" == "icp" ]]; then
        echo "<LI>Login to IBM Cloud Private"
        echo "<XMP>cloudctl login</XMP>"
      else 
        echo "Unsupported environment ${TGTTYPE}"
      fi
      echo "<LI>Create objects for kubernetes"
      echo "<XMP>kubectl apply -f deploy-kube/deploy-kube.yaml</XMP>"
    fi
  else
    line=$(echo $line | sed -e "s/\:applname./$APPLNAME/g" | sed -e "s/\:appltype./$APPLTYPE/g" | sed -e "s,\:tgtdir.,$TGTPATH,g" | sed -e "s/\:tgttype./$TGTTYPE/g")
    echo "$line"
  fi
done > $TGTPATH/result.html
