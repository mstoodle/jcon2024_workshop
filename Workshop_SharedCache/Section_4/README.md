Section_4

In this section of the workshop, we're going to try running Apache Tomcat with a
different JDK (IBM Semeru Runtimes) than the Eclipse Temurin JDK that comes
pre-installed. We have a small challenge: Tomcat comes in a container and
Semeru Runtimes also comes in a container. To resolve this dilemma, our
Dockerfile will use a multi-stage build to copy the JDK from the Semeru
Runtimes container into our new container that will be based on (FROM)
the Tomcat container.

We'll be using Tomcat v10 to stay with Java 17 consistently through the entire
workshop. In this section of the workshop, we'll also be initially disabling
the Semeru Runtime Shared Classes Cache.

Let's get started!

1. Build a tomcat container that contains the sample application. There is
a Dockerfile.tomcat_semeru.noscc file provided that first copies the Semeru Runtimes
JDK into the container and then copies the sample.war file. This Dockerfile also
adds the command-line option -Xshareclasses:none which completely disables any
class sharing for Semeru Runtimes.

Run the following command:

	$ podman build --network=host -f Dockerfile.tomcat_semeru.noscc -t tomcat_semeru.noscc

3. Run the container. It will automatically start the Tomcat server with the
sample application. Run the following command and wait for the server to start:

	$ podman run --cpus=1 --network=host --name=tomcat_semeru.noscc --replace -it tomcat_semeru.noscc > log.cpu1

Just like in the previous section, this starts the server with 1 CPU core.

4. (Ignore step 4 if you already have podman stats running in another terminal window)
Go to another terminal window and log into the workshop container. Run the following command
in another terminal window:

	$ podman exec --privileged -it workshop-main /bin/bash

This will connect to the running workshop container so that you can run another command there
while the tomcat server is running.  Use podman stats to observe the memory use of the container.
	$ podman stats

5. Review the memory use for the server

The podman stats command shows various statistics about all containers running within the main workshop
container. For example, you should see something like:

	ID            NAME                CPU %      MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	ef1846553ffb  tomcat_semeru.noscc 41.53%     41.73MB / 2.047GB  2.04%       0B / 0B     0B / 0B     35          2.011569s   41.53%

which shows the Tomcat server you started in step 3 running with only 42MB of memory. Compared to
starting Tomcat with Eclipse Temurin (with the HotSpot VM), when running this container uses about
40% less memory just by replacing the Temurin JDK with the Semeru Runtimes JDK.

Another way to think about that is that starting tomcat with Temurin consumes 62% more memory
than with Semeru Runtimes.

But keep in mind this measurement is only after startup and does not necessarily mean that the server
will continue to use less memory under load (although that has been the general finding). We can't
really test under load with the sample application, though, so you'll have to investigate this aspect
further on your own if you're interested.

6. Hit control-C to stop the server.

Once you stop the server, you can run the startTime.awk script to find out how long it took to start
the server. Let's see what that looks like:

	$ ./startTime.awk log.cpu1
	Server initiated 1715356585620868352, up at 1715356587598000000
	Full start time is 1977.13 ms

This message shows the server started in just under 2 seconds, which is really a LOT longer than
with Temurin! Don't fear, however, this isn't the best Semeru Runtimes can do.

7.  Before we improve on that time, however, first start and stop the server a few times and use the
startTime.awk script to see how reliable this start time is. You can also try running with 2 cores
to see what that does:
	$ podman run --cpus=2 --network=host --name=tomcat_semeru.noscc --replace -it tomcat_semeru.noscc > log.cpu2

With 2 cores, the podman stats are:
	ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	d6c64ea6596d  tomcat_semeru.noscc  0.22%       42.09MB / 2.047GB  2.06%       0B / 0B     0B / 0B     36          2.186217s   11.56%

So not much change in memory usage, at least. How about the start time?
	$ ./startTime.awk log.cpu2
	Server initiated 1715357245252879360, up at 1715357246401000000
	Full start time is 1148.12 ms

Well, it improved dramatically, as you'd expect, and it's not as much behind Temurin as it was on
one core. But it's still very far behind. Don't give up yet! In the next section, Semeru Runtimes
will improve dramatically!

8. You're done! 

This completes the fourth section in the workshop!

In this section we added performance results like these:

JDK		Core limit	Start time	Memory usage after start
Temurin		1 core		1152.47ms	68MB
Semeru NOSCC	1 core		1977.13ms	42MB

Temurin		2 cores		633.684ms	73MB
Semeru NOSCC	2 cores		1148.12ms	42MB

Move on to the next section to see what happens when we activate the Shared Classes Cache in
IBM Semeru Runtimes and run the Tomcat server with the same sample application. You should see
this picture reverse!
