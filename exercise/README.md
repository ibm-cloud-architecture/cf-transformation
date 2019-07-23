# Application Migration Exercises

These exercises provide step-by-step instructions on how to use the Cloud Foundry migration tool to migrate a variety of sample applications to two different target cloud platforms, OpenShift or IBM Kubernetes Service. The sample applications migrated are:

- Java hello-world application using the `ibm-websphere-liberty` buildpack, and requiring some backend services. The source code is pulled from a local directory.
- Different Java hello-world application using the `ibm-websphere-liberty` buildpack and no backend services. The source code is pulled from a github repository.
- Simple Java Spring Boot application using the `java` (Tomcat) buildpack and no backend services. The source code is pulled from a github repository.
- Simple Node.js hello-world application using the `nodejs` buildpack and no backend services. The source code is pulled from a github repository.
- Node.js application using the `nodejs` buildpack and requiring a Cloudant database backend service. The source code is pulled from a github repository.
 
The exercises below describe migrating each of these sample applications to their respective target cloud platform:

- [OpenShift](openshift.md)
- [IBM Kubernetes Service](iks.md)

