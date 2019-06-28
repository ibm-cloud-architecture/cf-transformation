# Cloud Foundry vs Kubernetes

The application in Cloud Foundry is configured as: 

![CloudFoundry app](images/cf.PNG)

The application in Kubernetes is configured as:

![Kubernetes app](images/kube.PNG)

The application deployment to Cloud Foundry is performed using the command `cf push`. While this is very simple, it allows relatively little control over how the application is deployed and managed. Kubernetes provides much more control over these aspects. However, in Kubernetes, there are several steps to perform staging of the application. 

![App Staging](images/staging.PNG)
