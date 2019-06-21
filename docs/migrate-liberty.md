# Migrate CloudFoundry Liberty app

To migrate CloudFoundry application to Kubernetes environment, you should be able to do the following:

- Perform the changes that are performed by the buildpack
- Quickly build a deployable image for Kubernetes
- Actually build the application in Kuberentes

This toolkit will help you on the first 2 items.

## Emulating the buildpack

The following are the important things that is performed by the buildpack:

- Install java and liberty into the image (which is not needed as you can start with a Liberty image)
- Build/modify server.xml
- Read dependent services and create declarative statement in runtime-vars.xml 

This toolkit :wq
