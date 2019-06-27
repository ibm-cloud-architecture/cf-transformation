# CF to Kubernetes migration tool
---
## Migration concepts

- Provide a Cloud Foundry application developer to quickly able to migrate and deploy on to a Kubernetes environment, be it an OpenShift or IBM Cloud Private environment
- Minimize learning curve needed to deploy and develop application on a new platform
- Pre-requisites:
	- Known application type (known buildpack)
	- Known service bindings 
	- Manifest file 

---
@snap[west span-60 text-64]
## Kubernetes and OpenShift for CloudFoundry users
@snapend
---
## CloudFoundry application architecture
![IMAGE](docs/images/cf.PNG)
---
@snap[north-east span-99 text-09]
## Kubernetes application architecture 
@snapend

@snap[west span-45 text-06]

@ul[](false)
- In Kubernetes applications are running in Pods, which is similar to CloudFoundry containers
- The Service perform load balancing for all the pod instances and then external requests can be retrieved using a LoadBalancer service or an Ingress entry. The Go Router in CloudFoundry performs these capabilities
- The Backend Services that the application uses are typically accessed using information from ConfigMaps or credentials from Secrets; in CloudFoundry VCAP_SERVICES environment variable is created for the application instance for accessing these Backend Services
@ulend
@snapend
@snap[east span-55 text-06]
![IMAGE](docs/images/kube.PNG)
@snapend
---
@snap[north-east span-99 text-09]
## OpenShift application architecture 
@snapend

@snap[west span-45 text-06]

@ul[](false)
- OpenShift is based on Kubernetes technology, hence a lot of the concepts of Kubernetes applies to OpenShift
- OpenShift uses Routes in place of Ingress entry, this is much more similar to CloudFoundry GO router with dynamically allocated hostnames that is addressable externally
- OpenShift uses DeploymentConfig, which has more capabilities then a Kubernetes Deployment for application automatic (re)-deployment when the Image or Configuration does change
@ulend
@snapend
@snap[east span-55 text-06]
![IMAGE](docs/images/oc.PNG)
@snapend
---
## Application Staging

- Collect build artifact, including perform maven, gradle or other build mechanism
- Application is then staged into the Cloud platform; this staging process is typically split into:
	- Container image creation
	- Application deployment

![Application Staging](docs/images/staging.PNG)
---
@snap[north-east span-99 text-09]
## Application Staging 
@snapend
@snap[west span-50 text-06]
### CloudFoundry
All the following are performed by `cf push`
@ul[](false)
- The CLI uploads application artifacts to CloudFoundry
- CloudFoundry selects the appropriate BuildPack
- BuildPack prepares the artifacts to create a runnable unit (**Droplet**)
- CloudFoundry stores the Droplet in the **Blob store**
- CloudFoundry deploys the Droplet into its Runtime as a **Garden Container** and provides VCAP_SERVICES to access backend services
- CloudFoundry associates the appropriate **Router entry**
@ulend
@snapend

@snap[east span-50 text-06]
### OpenShift
@ul[](false)
- Using a **BuildConfig** generates an **ImageStream** in OpenShift; the image can be build using Dockerfile or S2I process<br>`oc start-build <buildconfig_name>`
- Create ConfigMap and Secrets to access backend services
- Use a Template object that contains at least a **DeploymentConfig** (with **Pod** definition), **Service** and **Route**:<br>`oc new-app -f <template.yaml>`
@ulend
@snapend
---
@snap[north-east span-99 text-09]
## Application Staging 
@snapend
@snap[west span-50 text-06]
### CloudFoundry
All the following are performed by `cf push`
@ul[](false)
- The CLI uploads application artifacts to CloudFoundry
- CloudFoundry selects the appropriate BuildPack
- BuildPack prepares the artifacts to create a runnable unit (**Droplet**)
- CloudFoundry stores the Droplet in the **Blob store**
- CloudFoundry deploys the Droplet into its Runtime as a **Garden Container** and provides VCAP_SERVICES to access backend services
- CloudFoundry associates the appropriate **Router entry**
@ulend
@snapend

@snap[east span-50 text-06]
### Kubernetes
@ul[](false)
- Create a **docker image** using a Dockerfile and store the image in a **Docker repository**<br/>`docker build …`<br/>`docker push …`
- Create ConfigMap and Secrets to access backend services
- Use deployment YAML to deploy docker image into a **Kubernetes Pod** in a Deployment or DeploymentConfig<br/>`kubectl apply -f …`
- Use the Service YAML to associate the pods to a **Kubernetes Service** and optionally define it to an **Ingress** or **OpenShift Route**<br/>`kubectl apply -f …`
@ulend
@snapend

---
@snap[west span-60 text-64]
## CF migration tool
@snapend
---

## Migration approach


- Allow developer to understand the process to deploy in Kubernetes
- Build additional configuration files that should not change much provided the application is not changed significantly
- Let developer to deploy manually to Kubernetes or load the process to automatically deploy using Jenkins pipeline
- Prevent automation to create generic migration tool to have a CF application run directly in Kubernetes using buildpack simulation (ie https://buildpacks.io)
- Tools should be run just once when developer need a quick jump-start into Kubernetes

---

## Migration scripts

The cf-migrate flow (Runtime/Buildpack specific):

- Extract application artifact (get_source.sh)
- Generate application configuration (server_xml.sh and vcap-liberty.sh for liberty; vcap.sh for all others)
- Generate Dockerfile (create_dockerfile.sh)
- Generate deployment yaml files (create_yaml.sh)
- Generate Jenkinsfile (not in MVP)
- Produce readme of what artifacts are produced and how to invoke the deployments (writeout.sh)


---

## Migration tool prerequisites

- Prerequisites:
	- bash
	- jq
	- git
	- curl
	- xmlstarlet
	- maven or gradle
- Or use the provided Docker image: ibmcloudacademy/cfmigrationtool
	- Get the container image: <br/>`docker pull ibmcloudacademy/cfmigrationtool` 
	- Use a path from the host that you will use to store the output, assuming that you use /Users/ibmuser/data:<br/>
`docker run --net=host -v /Users/ibmuser/data:/data -it ibmcloudacademy/cfmigrationtool bash`
---
## Limitation

Current limitation for the tool:

- Only support gradle or maven as the build mechanism
- Limited logic to manage complex application (ie multiple war files or non npm based nodejs)
- Liberty apps must already have the DataSource and JDBC definition in server.xml file (will not build a JDBC structure in server.xml)
- Must manually supply a VCAP_SERVICES content
---

## Running migration tool

- Download the tool from GitHub:<br/>
`git clone https://github.com/ibm-cloud-architecture/cf-transformation` 
- Change the directory to the migrate sub-directory:<br/>
`cd cf-transformation/migrate `
- Get the content of your application VCAP_SERVICES from Cloud Foundry (optional):<br/>
`cf env <appname>  > vcap.json`  
- Run the migration tool against your source:<br/>
`./cf-migrate.sh -s <source> -t <tempdir> -b <app type> -e <target type>` 

	- `-s`: migration source, can be local path or a HTTPS git repository link
	- `-t`: the processing and result path, useful for defining container shared path
	- `-b`: application or buildpack type (ibm-websphere-liberty, java, nodejs)
	- `-e`: target type (openshift, iks, icp)	
---
## Sample output
![IMAGE](docs/images/toolrun.PNG)
