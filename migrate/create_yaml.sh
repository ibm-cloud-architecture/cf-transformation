#!/bin/bash

# Get arguments

target_dir=$1

if [ -z "$target_dir" ]
then
  exit 999
fi

app_name=$2

if [ -z "$app_name" ]
then
  exit 999
fi

buildpack_name=$3

if [ -z "$buildpack_name" ]
then
  exit 999
fi

# Copy Deployment YAML File templates

chmod -R u+wx ${target_dir}

deploy_oc=${target_dir}/deploy-openshift/deploy-template.yaml
deploy_kube=${target_dir}/deploy-kube/deploy-kube.yaml

mkdir ${target_dir}/deploy-openshift

if [[ $? -gt 0 ]]; then
  echo "OpenShift Yaml file directory creation failed"
  exit 50
fi

mkdir ${target_dir}/deploy-kube

if [[ $? -gt 0 ]]; then
  echo "Kube Yaml file directory creation failed"
  exit 50
fi

# Capture VCAP SERVICES for Kubernetes secrets

os=$(uname)
if [[ "$uname" != "Darwin" ]]; then
  b64opt="-w 0"
else
  b64opt=""
fi

if [ -f vcap.json ]; then
  vcap=$(cat vcap.json | base64 $b64opt)
else
  vcap=$(echo "{}" | base64)
fi

# Customize deployment YAML for different Buildpacks

case ${buildpack_name} in
  *liberty*)
  sed -e "s/\${APP_NAME}/${app_name}/g" -e "s/\${APP_ARTIFACT_ID}/${app_name}/g" -e "s/\${TAG}/latest/g" -e "s/\${VCAP}/${vcap}/g" -e "/terminationMessagePolicy*/r deploy-libertycode.yaml" deploy-template.yaml > ${deploy_oc}
  sed -e "s/\${APP_NAME}/${app_name}/g" -e "s/\${APP_ARTIFACT_ID}/${app_name}/g" -e "s/\${TAG}/latest/g" -e "s/\${VCAP}/${vcap}/g" deploy-kube.yaml > ${deploy_kube}
  ;;
  *java*)
  sed -e "s/\${APP_NAME}/${app_name}/g" -e "s/\${APP_ARTIFACT_ID}/${app_name}/g" -e "s/\${TAG}/latest/g" -e "s/9080/8080/g" -e "s/\${VCAP}/${vcap}/g" deploy-template.yaml > ${deploy_oc}
  sed -e "s/\${APP_NAME}/${app_name}/g" -e "s/\${APP_ARTIFACT_ID}/${app_name}/g" -e "s/\${TAG}/latest/g" -e "s/9080/8080/g" -e "s/\${VCAP}/${vcap}/g" deploy-kube.yaml > ${deploy_kube}
  ;;
  *node*)
  sed -e "s/\${APP_NAME}/${app_name}/g" -e "s/\${APP_ARTIFACT_ID}/${app_name}/g" -e "s/\${TAG}/latest/g" -e "s/9080/8000/g" -e "s/\${VCAP}/${vcap}/g" -e "/env\:*/r deploy-nodecode.yaml" deploy-template.yaml > ${deploy_oc}
  sed -e "s/\${APP_NAME}/${app_name}/g" -e "s/\${APP_ARTIFACT_ID}/${app_name}/g" -e "s/\${TAG}/latest/g" -e "s/9080/8000/g" -e "s/\${VCAP}/${vcap}/g" -e "/env\:*/r deploy-nodecode-kube.yaml" deploy-kube.yaml > ${deploy_kube}
  ;;
  *) echo "Unsupported Buildpack: "${buildpack_name}; exit 1;;
esac;

exit 0
