Section_2

In this section of the workshop, we'll be running the Liberty server in its default mode to
run the Getting Started application. We'll find that the server starts much faster (in a
little more than half the time) and can use less memory because the shared classes cache
does not need to remain resident.

1. Build the getting started application

	$ mvn package

2. Build an OpenLiberty container that contains the getting started application. There is
a Dockerfile.liberty_scc file provided that enables and populates the Semeru Runtimes shared
classes cache automatically when this container is built. Run the following command:

	$ podman build --network=host -f Dockerfile.liberty_scc -t liberty_scc .

3. Run the container. It will automatically start the OpenLiberty server with the
loaded getting started application. Run the following commadn and wait for the server
to start:

	$ podman run --network=host --name=liberty_scc --replace -it liberty_scc

Look for the elapsed time to start the server. You'll see a line that ends with something like::
	The defaultServer server started in 1.702 seconds.

Comparing to the Liberty server we started in Section_1, this server using the prepopulated
shared classes cache starts in about 55% of the time (1.702 seconds versus 3.043 seconds),
a dramatic improvement!

4. At this point the server is loaded and you should be able to access the application from your
host web browser by loading "localhost:9080". Verify the server page loads.

5. (Ignore steps 5 and 6 if you already have podman stats running in another terminal window)
Go to another terminal window and log into the workshop container. Run the following command
in another terminal window:

	$ podman exec -it --network=host workshop/main /bin/bash

This will connect to the running workshop container so that you can run another command there
while the Liberty server is running.

6. (Ignore steps 5 and 6 if you already have podman stats running in another terminal window)
Use podman stats to observe the memory use of the container.

$ podman stats

This command shows various statistics about all containers running within the main workshop
container. For example, you should see something like:

ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
f6ecefd2dace  liberty_scc        3.51%       97.9MB / 2.047GB   4.78%       0B / 0B     0B / 0B     59          4.626379s   15.75%

which shows the Liberty server you started in step 3 running with 98MB of memory. The memory use
is lower because the shared memory used by the shared cache can be shared by multiple instances
and so isn't counted as part of the memory use for the container. If you were to start a second,
third, fourth, etc. server on the same machine connected to the same shared cache, there would
be only one copy of the cache loaded in memory. Although it doesn't happen in this workshop, it
is pretty common in production deployments for multiple servers to be running on the same physical
node so these savings are real even though completely subtracting it from the memory usage seems
overboard especially with only one server running.

You can leave this podman stats command running for step 7.

7. Hit control-C to stop the server.

8. Start and stop the server a few times to get a feeling for how the startup time and memory
consumption varies in different server instances.

Repeat steps 3 and 7 a few times, noting the elapsed startup time in each run and checking the
memory usage figure in the other terminal window you started in step 6.

You won't see exactly the same time and memory usage in different runs, but the server startup time
usually falls within a few tenths of a second and the memory usage is typically within a few MB.

9. Optionally, stop the podman stats command running in the other terminal window by hiting
control-C. You can also leave this command running for the other sections of this workshop so
you can keep watching the statistics for the containers you use.

9. You're done! 

This completes the second section in the workshop! Move on to the next section to see if we can
use the Semeru Runtimes Shared Classes Cache to help another server to start faster!
