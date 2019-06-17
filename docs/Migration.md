# CF Migration tool - README

This tool assists you in migrating CloudFoundry application to Kubernetes based platform.

## The approach

The tool is not supposed to run for building the application. The tool builds all the necessary assets that allows you to deploy in Kubernetes environment. The generated assets from this tool can be used to test and deploy the application and then assists you to create an automated DevOps pipeline. The tool is only meant to be run once, as long as the application is not changed significantly. 

The approach that we take is meant to help you transition into a full Kubernetes developer instead of a tool that automate you to build a Kubernetes application from a CloudFoundry application source. The resulting assets are typically:

- Configuration files for the application code
- Dockerfile to generate the image
- YAML configuration files to deploy to Kubernetes

## The tool

The tool is packaged as a GitHub repository in https://github.com/ibm-cloud-architecture/cf-transformation. Sample applications are provided in the exemplar directory. 

1. Download the tool from GitHub:

		git clone https://github.com/ibm-cloud-architecture/cf-transformation

2. Change the directory to the migrate sub-directory:

		cd cf-transformation/migrate

3. Run the migration tool against your source:

		./cf-migrate.sh -s <source> -t <tempdir> -b <app type> -e <target type> 

	Where:
		- `-s` source path or source git repository URL
		- `-t` the temporary conversion directory where the work and output will be performed (default: /tmp/convdir)
		- `-b` the application type (buildpack) ibm-websphere-liberty, java, nodejs etc
		- `-e` target environment: openshift, iks or icp




## The output

The tool run is shown in:

![Tool run](images/toolrun.PNG)

It mainly produces an HTML file that you can view for deploying your application to Kubernetes:

![HTML result](images/result.PNG)


You can run the commands listed in the result.html to deploy your application to Kubernetes.

The following are specific output and recommendation for different application types (Buildpacks):

- [ibm-websphere-liberty](liberty.md)
- [nodejs](nodejs.md)
- [java springboot](java.md)
