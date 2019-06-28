# Running the migration tool using a Docker container 

We have provided a Docker container that you can use to run the migration tool.
Using a docker container allows you to run the tool without having to install all the prerequisite software on your own machine.
Assuming that you have docker running, do the following steps to run the migration tool from the container:


1. Get the container image:

		docker pull ibmcloudacademy/cfmigrationtool

2. In the command to start the container, provide the path to an existing directory on your machine that the tool will use for its conversion and to store the output. The following example assumes that you are using `/Users/ibmuser/data`:

		docker run --net=host -v /Users/ibmuser/data:/data -v /var/run/docker.sock:/var/run/docker.sock -it ibmcloudacademy/cfmigrationtool bash

3. You will get a bash prompt from inside the container. You can then perform the migration tasks listed in the documentation and exercises. Since the directory you provided in the previous command is mapped to the path `/data` inside the container, remember to use the path `/data` as your target path (the `-t` parameter for the `cf-migrate.sh` script)



