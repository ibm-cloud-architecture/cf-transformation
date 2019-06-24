#!/bin/bash

target_dir=$1

if [ -z "$target_dir" ]
then
  exit 999
fi

buildpack_name=$2

if [ -z "$buildpack_name" ]
then
  exit 999
fi

dockerfile=${target_dir}/Dockerfile

chmod -R a+x ${target_dir}

echo "# Base Image" > ${dockerfile}

case ${buildpack_name} in
  *liberty*)
    echo "FROM websphere-liberty:kernel" >> ${dockerfile}
    echo " " >> ${dockerfile}
    echo "# Copy application artifacts & configuration" >> ${dockerfile}
    appfile=$(basename ${target_dir}/apps/*.war)
    echo "RUN mkdir -p /config" >> ${dockerfile}
    echo "RUN mkdir -p /config/dropins" >> ${dockerfile}
    echo "COPY apps/${appfile} /config/dropins/${appfile}" >> ${dockerfile}
    echo "# RUN chown 1001:0 /config/dropins/${appfile}" >> ${dockerfile}
    echo "COPY server.xml /config/server.xml" >> ${dockerfile}
    echo "# RUN chown 1001:0 /config/server.xml" >> ${dockerfile}
    if [ -f "${target_dir}/runtime-vars.xml" ] ; then
      echo "COPY runtime-vars.xml /config/runtime-vars.xml" >> ${dockerfile}
      echo "# RUN chown 1001:0 /config/runtime-vars.xml" >> ${dockerfile}
    fi
    echo " " >> ${dockerfile}
    echo "# Install Liberty features" >> ${dockerfile}
    echo "RUN installUtility install --acceptLicense defaultServer" >> ${dockerfile}
    echo " " >> ${dockerfile}
    ;;

  *java*)
    if [ -f ${target_dir}/apps/*.war ] ; then
        echo "FROM tomcat" >> ${dockerfile}
        echo " " >> ${dockerfile}
        echo "# Copy application artifacts & configuration" >> ${dockerfile}
        appfile=$(basename ${target_dir}/apps/*.war)
        echo "RUN mkdir -p /usr/local/tomcat/webapps" >> ${dockerfile}
        echo "COPY apps/${appfile} /usr/local/tomcat/webapps/${appfile}" >> ${dockerfile}
    else
        echo "FROM java" >> ${dockerfile}
        echo " " >> ${dockerfile}
        echo "# Copy application artifacts & configuration" >> ${dockerfile}
        appfile=$(basename ${target_dir}/*.jar)
        echo "COPY ${appfile} /" >> ${dockerfile}
        echo "CMD java -cp /${appfile} org.springframework.boot.loader.JarLauncher" >> ${dockerfile}
    fi
    echo " " >> ${dockerfile}
    ;;

  *nodejs*)
    echo "FROM node" >> ${dockerfile}
    echo "RUN mkdir /app" >> ${dockerfile}
    echo "COPY . /app" >> ${dockerfile}
    echo "WORKDIR /app" >> ${dockerfile}
    echo "RUN cd /app;npm install" >> ${dockerfile}
    echo "CMD npm start" >> ${dockerfile}
    echo " " >> ${dockerfile}
    ;;

  *) echo "Unsupported Buildpack: "${buildpack_name}; exit 1;;
esac;

echo "# Optional functionality" >> ${dockerfile}
echo "# ARG SSL=true" >> ${dockerfile}
echo "# ARG MP_MONITORING=true" >> ${dockerfile}
echo " " >> ${dockerfile}
echo "# Add interim fixes (optional)" >> ${dockerfile}
echo "# COPY --chown=1001:0  interim-fixes /opt/ibm/fixes/" >> ${dockerfile}
echo " " >> ${dockerfile}
echo "# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes" >> ${dockerfile}
echo "# RUN configure.sh" >> ${dockerfile}

exit 0
