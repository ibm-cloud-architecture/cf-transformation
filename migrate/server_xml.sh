#!/bin/bash
# This program replaces the activity that are performed by CloudFoundry buildpack
# $buildpack-build.sh
# Input is the path where the artifact resides ${CONVDIR}/${tpath}

source=$1
CODEDIR=$( dirname "${BASH_SOURCE[0]}" )
if [ $CODEDIR == "." ]; then
  CODEDIR=`pwd`
fi
apptype="war"

if [[ -f "${source}" ]]; then
  fn=`basename ${source}`
  source=`dirname ${source}`
fi

cd ${source}
if [[ ! -f "${source}/server.xml" ]] ; then
  # Create default server.xml
  echo "Create default server.xml"
  cp $CODEDIR/server.xml .
  # Insert feature manager
  xmlstarlet ed \
    -s /server -t elem -n featureManager \
    -s /server/featureManager -t elem -n feature -v servlet-3.1 \
    server.xml | xmlstarlet fo -s 2 > t1.xml; cp t1.xml server.xml
  # insert webContainer
  xmlstarlet ed \
    -s /server -t elem -n webContainer \
    server.xml | xmlstarlet fo -s 2 > t1.xml; cp t1.xml server.xml
  # insert Application information
  xmlstarlet ed \
    -s /server -t elem -n application \
    -i /server/application -t attr -n name -v "myapp" \
    -i /server/application -t attr -n context-root -v "\/" \
    -i /server/application -t attr -n location -v "myapp.${apptype}" \
    -i /server/application -t attr -n type -v "${apptype}" \
    server.xml | xmlstarlet fo -s 2 > t1.xml; cp t1.xml server.xml
else
  echo "Working with existing server.xml"
  #xmlstarlet ed \
  #  -d /server/httpEndpoint 
  #  server.xml | xmlstarlet fo -s 2 > t1.xml; cp t1.xml server.xml
fi
  echo "Performing server.xml mods"
  # insert webContainer
  xmlstarlet ed \
    -s /server -t elem -n webContainer \
    -i /server/webContainer -t attr -n trustHostHeaderPort -v true \
    -i /server/webContainer -t attr -n extractHostHeaderPort -v true \
    server.xml | xmlstarlet fo -s 2 > t1.xml; cp t1.xml server.xml
  # insert http and https endpoint
#  xmlstarlet ed \
#    -s /server -t elem -n httpEndpoint \
#    -i /server/httpEndpoint -t attr -n id -v defaultHttpEndpoint \
#    -i /server/httpEndpoint -t attr -n host -v "*" \
#    -i /server/httpEndpoint -t attr -n httpPort -v "\${port}" \
#    server.xml | xmlstarlet fo -s 2 > t1.xml; cp t1.xml server.xml
  # insert runtime-vars
  xmlstarlet ed \
    -s /server -t elem -n include \
    -i /server/include -t attr -n location -v runtime-vars.xml \
    server.xml | xmlstarlet fo -s 2 > t1.xml; cp t1.xml server.xml
  # insert logging info
  xmlstarlet ed \
    -s /server -t elem -n logging \
    -i /server/logging -t attr -n consoleLogLevel -v INFO \
    -i /server/logging -t attr -n logDirectory -v "\${logdir}" \
    server.xml | xmlstarlet fo -s 2 > t1.xml; cp t1.xml server.xml
  # disable welcome page
  xmlstarlet ed \
    -s /server -t elem -n httpDispatcher \
    -i /server/httpDispatcher -t attr -n enableWelcomePage -v false \
    -i /server/httpDispatcher -t attr -n trustedSensitiveHeaderOrigin -v "\*" \
    server.xml | xmlstarlet fo -s 2 > t1.xml; cp t1.xml server.xml

