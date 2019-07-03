FROM ubuntu:16.04
RUN apt-get update;apt-get upgrade -y
RUN apt-get update;apt-get install -y git curl wget jq xmlstarlet maven gradle 
RUN curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github" | tar -zx;mv cf /usr/local/bin
RUN wget https://public.dhe.ibm.com/cloud/bluemix/cli/bluemix-cli/0.16.2/IBM_Cloud_CLI_0.16.2_amd64.tar.gz;tar -xzvf IBM_Cloud_CLI_0.16.2_amd64.tar.gz;rm IBM_Cloud_CLI_0.16.2_amd64.tar.gz;./Bluemix_CLI/install
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl;chmod a+x kubectl;mv kubectl /usr/local/bin/kubectl
RUN wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz;tar -xzvf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz;mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/local/bin/oc
CMD bash
RUN apt-get update;apt-get install -y default-jdk
RUN apt-get update;apt-get install -y software-properties-common apt-transport-https
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -;add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable";apt-get update; apt-get install -y docker-ce
RUN apt-get update;apt-get install -y vim nodejs npm
RUN ibmcloud plugin install container-service
RUN ibmcloud plugin install container-registry

