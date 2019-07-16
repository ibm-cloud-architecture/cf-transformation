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
- Applications run in Pods, which are similar to Cloud Foundry droplet containers
- A Kubernetes Service performs load balancing for all the pod instances
	- External requests can be directed using a LoadBalancer service or an Ingress entry
	- Kubernetes Service performs similar functions to the Go Router in Cloud Foundry
- Backend Services for the application are typically accessed using information from ConfigMaps and/or credentials from Secrets
	- In Cloud Foundry this access information for backend services is read from VCAP_SERVICES environment variables
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
- OpenShift is based on Kubernetes technology
	- Most concepts of Kubernetes apply to OpenShift
- OpenShift uses Routes in place of an Ingress entry
	- Similar to Cloud Foundry GO router with dynamically allocated hostnames that are addressable externally
- OpenShift uses a DeploymentConfig, which has more capabilities than a Kubernetes Deployment
	- Automatic (re)-deployment when the Image or Configuration changes
@ulend
@snapend
@snap[east span-55 text-06]
![IMAGE](docs/images/oc.PNG)
@snapend
---
## Application Staging

- Collect build artifact, including perform maven, gradle or other build mechanism
- Application is then staged into the Cloud platform; this staging process is typically split into:
	- Application container image creation
	- Application container deployment

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
- CloudFoundry associates the appropriate **Router** entry
@ulend
@snapend

@snap[east span-50 text-06]
### OpenShift
@ul[](false)
- Using a **BuildConfig** generates an **ImageStream** in OpenShift; 
	- The image can be build using Dockerfile or S2I process
	<br>`oc start-build <buildconfig_name>`
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

- Allow developer to understand the process of deploying to Kubernetes
- Generate deployment configuration files for OpenShift & Kubernetes
	- Should not need modification unless the application is changed significantly
- Allow developer to deploy manually to Kubernetes or use artifacts to automatically deploy using Jenkins pipeline
- Generate supportable application container images using standard base images
	- Do not just simulate what the Cloud Foundry buildpack does (ie https://buildpacks.io)
	- Do not create the same application container image as Cloud Foundry does
- Tool should only need to be run once to migrate to OpenShift or Kubernetes
	- After that, application can be maintained in the target environment

---
## Migration scripts

Main script cf-migrate.sh flow (Runtime/Buildpack specific):

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
	- jdk
	- maven or gradle
- Or use the provided Docker image: ibmcloudacademy/cfmigrationtool
	- Get the container image: <br/>`docker pull ibmcloudacademy/cfmigrationtool` 
	- Use a path from the host that you will use to store the output, assuming that you use /Users/ibmuser/data:<br/>
`docker run -p 8000:8000 -v /Users/ibmuser/data:/data -it ibmcloudacademy/cfmigrationtool bash`
---
## Limitation

Current limitation for the tool:

- Only support gradle or maven as the build mechanism
- Limited logic to manage complex application (ie multiple war files or non npm based nodejs)
- Liberty apps must already have the DataSource and JDBC definition in server.xml file 
	- Will not build a JDBC structure in server.xml
- Must manually supply a VCAP_SERVICES environment variable value 
	- The command is provided in documentation
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
---
@snap[north-east span-99 text-09]
## Using the Web application
@snapend
@snap[west span-50 text-06]

- Run the Web application

	`cd /cf-transformation/webapp`
	`npm install`
	`nodejs app.js`

- Access the Web application in `http://localuser:8000`
- Specify the options and click **Run migration**
- Once the messages of the script appear, click **Show result**
- The result.html is shown in the page
@snapend

@snap[east span-50]
![IMAGE](docs/images/index2.png)
@snapend
---
## Deploy output (1 of 2)
![IMAGE](docs/images/output1.PNG)
---
## Deploy output (2 of 2)
![IMAGE](docs/images/output2.PNG)
