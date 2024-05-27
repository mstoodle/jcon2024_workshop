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

	$ podman build --network=host -f Dockerfile.liberty_temurin -t liberty_temurin .

3. Run the container. It will automatically start the OpenLiberty server with the
loaded getting started application. Run the following commadn and wait for the server
to start:

	$ podman run --cpus=1 --network=host --name=liberty_temurin --replace -it liberty_temurin

Look for the elapsed time to start the server. You'll see a line that ends with something like::
	The defaultServer server started in 5.254 seconds.

4. (Ignore step 4 if you already have podman stats running) Go to another terminal window and log
into the workshop container. Run the following command in another terminal window:
	$ podman exec --privileged -it workshop-main /bin/bash

This will connect to the running workshop container so that you can run another command there
while the Liberty server is running. Run podman stats to observe the memory use of the container.
	$ podman stats

5. The podman stats command shows various statistics about all containers running within the main
 workshop container. For example, you should see something like:

	ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	6b620b477183  liberty_temurin    2.01%       195.7MB / 2.047GB  9.56%       0B / 0B     0B / 0B     44          6.029899s   38.43%

which shows the Liberty server you started in step 3 running with 196MB of memory. You can leave
this podman stats command running for step 7; it will update the list of active containers about
every 5 seconds.

6. Hit control-C to stop the server.

7. Start and stop the server a few times to get a feeling for how the startup time and memory
consumption varies in different server instances.

Repeat steps 3 and 6 a few times, noting the elapsed startup time in each run and checking the
memory usage figure in the other terminal window you started in step 6.

You won't see exactly the same time and memory usage in different runs, but the server startup time
usually falls within a few tenths of a second and the memory usage is typically within a few MB..

You can also try increasing the number of cores to see how that impacts start time and memory usage:

	$ podman run --cpus=2 --network=host --name=liberty_temurin --replace -it liberty_temurin

And the server starts about twice as fast:
	The defaultServer server started in 2.531 seconds.

And it's using quite a bit more memory :

	ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	aefb65c00f43  liberty_temurin    2.07%       231.8MB / 2.047GB  11.32%      0B / 0B     0B / 0B     51          5.817187s   38.21%


We can even try with 4 cores, but the return on adding 2 additional CPU cores isn't very high:

	$ podman run --cpus=4 --network=host --name=liberty_temurin --replace -it liberty_temurin

The server does start a bit faster:
	The defaultServer server started in 1.913 seconds.

But memory usage also went up again from 2 cores:

	ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	7fa5cb1908b4  liberty_temurin    2.56%       271.7MB / 2.047GB  13.27%      0B / 0B     0B / 0B     57          7.370935s   32.31%

8. You're done! 

Let's start a table of performance results we can carry through the next few sections:

JDK			Cores		Start time	Memory usage
Temurin			1		5.524s		191MB
Temurin			2		2.531s		232MB
Temurin			4		1.913s		272MB


This completes this part of the workshop! Move on to the next Section to see how fast
OpenLiberty will load this application when we use the default Semeru Runtimes installation
with a prepulated shared classes cache.
