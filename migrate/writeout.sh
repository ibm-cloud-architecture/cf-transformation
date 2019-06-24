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
      echo "<XMP>oc login </XMP>"
      echo "<LI>Create application from the deploy template"
      echo "<XMP>oc new-app -f deploy-openshift/deploy-template.yaml -pTARGET_HOST=value -pTARGET_WORKSPACE=value</XMP>"
    else
      if [[ "$TGTTYPE" == "iks" ]]; then
        echo "<LI>Login to IBM Cloud"
        echo "<XMP>ibmcloud login</XMP>"
        echo "<XMP>ibmcloud ks cluster-config <clustername></XMP>"
        echo "<XMP>export KUBECONFIG=<configfile></XMP>"
      elif [[ "$TGTTYPE" == "icp" ]]; then
        echo "<LI>Login to IBM Cloud Private"
        echo "<XMP>cloudctl login</XMP>"
      else 
        echo "Unsupported environment ${TGTTYPE}"
      fi
      echo "<LI>Create linkage for any backend services"
      echo "<XMP>kubectl apply -f kube/parameter.yaml</XMP>"
      echo "<LI>Deploy the application into the cluster"
      echo "<XMP>kubectl apply -f kube/deployment.yaml</XMP>"
      echo "<LI>Generate the service for the application"
      echo "<XMP>kubectl apply -f kube/service.yaml</XMP>"
    fi
  else
    line=$(echo $line | sed -e "s/\:applname./$APPLNAME/g" | sed -e "s/\:appltype./$APPLTYPE/g" | sed -e "s,\:tgtdir.,$TGTPATH,g" | sed -e "s/\:tgttype./$TGTTYPE/g")
    echo "$line"
  fi
done > $TGTPATH/result.html
