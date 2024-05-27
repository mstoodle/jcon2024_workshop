Section_1 exercise

In this section of the workshop, we'll set up a Liberty container with the "Getting Started"
application and take some rough measurements of the start-up time and memory usage for this
container. In this section, we will be intentially not using the Semeru Runtimes Shared Classes
Cache to get an idea what the baseline is (note that this is not the default Liberty configuration,
which automatically prepopulates a shared classes cache; we'll be trying that out in Section_2).

Let's get started!

1. Build the getting started application in this directory:

	$ mvn package

2. Build an OpenLiberty container that contains the getting started application. There is
a Dockerfile.liberty_noscc file provided that specifically disables the Semeru Runtimes
shared classes cache when this container is built. Run the following command:

	$ podman build --network=host -f Dockerfile.liberty_noscc -t liberty_noscc .

3. Run the container. It will automatically start the OpenLiberty server with the
loaded getting started application. Run the following commadn and wait for the server
to start:

	$ podman run -p 9080:9080 --name=liberty_noscc --replace -it liberty_noscc

Look for the elapsed time to start the server. You'll see a line that ends with something like::
	The defaultServer server started in 3.043 seconds.

4. Go to another terminal window and log into the workshop container. Run the following command
in another terminal window:

	$ podman exec --privileged -it workshop-main /bin/bash

This will connect to the running workshop container so that you can run another command there
while the Liberty server is running.

5. Use podman stats to observe the memory use of the container.

	$ podman stats

This command shows various statistics about all containers running within the main workshop
container. For example, you should see something like:

	ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	b814b591a1da  liberty_noscc      3.44%       131MB / 2.047GB    6.40%       0B / 0B     0B / 0B     60          9.040596s   33.61%

which shows the Liberty server you started in step 3 running with 137MB of memory. You can leave
this podman stats command running for step 7; it will update the list of active containers about
every 5 seconds.

6. Hit control-C to stop the server.

7. Start and stop the server a few times to get a feeling for how the startup time and memory
consumption varies in different server instances.

Repeat steps 3 and 7 a few times, noting the elapsed startup time in each run and checking the
memory usage figure in the other terminal window you started in step 6.

You won't see exactly the same time and memory usage in different runs, but the server startup time
usually falls within a few tenths of a second and the memory usage is typically within a few MB..

8. Optionally, stop the podman stats command running in the other terminal window by hiting
control-C. You can also leave this command running for the other parts of this workshop so
you can keep watching the statistics for the containers you use.

9. You're done! 

This completes this part of the workshop! Move on to the next Section to see how fast
OpenLiberty will load this application when the shared cache has been created!
