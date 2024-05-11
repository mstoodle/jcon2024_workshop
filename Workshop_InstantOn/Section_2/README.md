Section_2

In this section of the workshop, we'll be running the Liberty server in its default mode to
run the Getting Started application. We'll find that the server starts much faster than with
the Eclipse Temurin JDK while at the same time using dramatically less memory.

1. Build the getting started application

	$ mvn package

2. Build an OpenLiberty container that contains the getting started application. There is
a Dockerfile.liberty_scc file provided that enables and populates the Semeru Runtimes shared
classes cache automatically when this container is built. Run the following command:

	$ podman build --network=host -f Dockerfile.liberty_scc -t liberty_scc .

3. Run the container. It will automatically start the OpenLiberty server with the
loaded getting started application. Run the following commadn and wait for the server
to start:

	$ podman run --cpus=1 --network=host --name=liberty_scc --replace -it liberty_scc

Look for the elapsed time to start the server. You'll see a line that ends with something like::
	The defaultServer server started in 2.971 seconds.

Comparing to the Liberty server we started in Section_1 with the Temurin JDK, this server 
starts in about 54% of the time (2.971 seconds versus 5.524 seconds): quite a dramatic improvement!

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
	178f3e6a5894  liberty_scc        2.50%       94.63MB / 2.047GB  4.62%       0B / 0B     0B / 0B     49          3.52296s    20.15%


which shows the Liberty server you started in step 3 running with 95MB of memory, less than
half of the 197MB of memory used by Temurin to start in this single core configuration.

You can leave this podman stats command running for step 7.

7. Hit control-C to stop the server.

8. Start and stop the server a few times to get a feeling for how the startup time and memory
consumption varies in different server instances.

Repeat steps 3 and 7 a few times, noting the elapsed startup time in each run and checking the
memory usage figure in the other terminal window you started in step 6.

You won't see exactly the same time and memory usage in different runs, but the server startup time
usually falls within a few tenths of a second and the memory usage is typically within a few MB.

You can also try runs with 2 cores to see what affect the additional CPU resources has.

	$ podman run --cpus=2 --network=host --name=liberty_scc --replace -it liberty_scc

This server starts in 1.933 seconds so adding a second core certainly helped.
	The defaultServer server started in 1.933 seconds.

In terms of memory usage:
	ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	1512571376e3  liberty_scc        2.13%       96.11MB / 2.047GB  4.69%       0B / 0B     0B / 0B     50          3.661607s   23.97%

So 2 cores helped to start the server faster but maybe used a little bit more memory. This 1MB could
just be variation, though, so more runs would be needed to draw a conclusive comparison on the
memory usage.

We can even try 4 cores and get a little more improvement but the return on investment isn't very
high given we added 2 extra CPU cores:
	$ podman run --cpus=4 --network=host --name=liberty_scc --replace -it liberty_scc

	The defaultServer server started in 1.718 seconds.


	ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	8af9f3867d37  liberty_scc  2.82%       96.71MB / 2.047GB  4.72%       0B / 0B     0B / 0B     56          3.994648s   25.13%

Memory usage might have gone up another 1MB, but again, more runs would be needed to confirm that is
not just run-to-run variation.

9. Optionally, stop the podman stats command running in the other terminal window by hiting
control-C. You can also leave this command running for the other sections of this workshop so
you can keep watching the statistics for the containers you use.

9. You're done! 

Let's update our performance table:
JDK			Cores		Start time	Memory usage
Temurin			1		5.524s		191MB
Semeru			1		2.971s		95MB

Temurin			2		2.531s		232MB
Semeru			2		1.933s		96MB

Temurin			4		1.913s		272MB
Semeru			4		1.718s		97MB

From the table, you can see that Semeru Runtimes manages to reach almost the same start-up performance
with half the CPU resources needed by the Temurin JDK. As more cores are made available to Temurin, the
server seems to be consistently using more memory after the server has started. With Semeru Runtimes,
however, this effect is much less pronounced and the overall memory usage is just a little over a
third of what's being used by Temurin.

Another way to express these results: a decision to use Temurin to start OpenLiberty results in
as much as 85% longer start times (1 core) and can use as much as 2.8 times as much memory (4 cores).
These differences can have a dramatic impact on responsiveness to changes in load as well as the
overall deployment costs, since more memory can translate to VM instances that cost more money.

This completes the second section in the workshop! In the next section, we'll see how these startup
times can be even more dramatically improved when using the Liberty and Semeru InstantOn capabilities.
