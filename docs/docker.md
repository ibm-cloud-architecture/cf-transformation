# Running the tool using Docker 

We provide a Docker container that you can use to run this tool.
Using a docker container, allow you to run this tool, without having to install all the prerequisites manually.
Assuming that you have docker running, the following steps allow you to start the container for running the tool:


1. Get the container image:

	docker pull ibmcloudacademy/cfmigrationtool

2. Use a path from the host that you will use to store the output, assuming that you use `/Users/ibmuser/data`:

	docker run --net=host -v /Users/ibmuser/data:/data -it ibmcloudacademy/cfmigrationtool bash

3. You will get a bash prompt from inside the container, you can then perform the tasks listed in the main tool page, only remember to use the path `/data` as your target path (from `-t` switch)



