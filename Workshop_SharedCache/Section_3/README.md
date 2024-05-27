Section_3

In this section of the workshop, we're going to establish the baseline startup time
and memory usage for a different server technology: Apache Tomcat. We're also going
to switch temporary away from IBM Semeru Runtimes to get a feel for how performance
varies with different JDKs.

We'll be running a different application than the "Getting Started" application used
in Section_1 and Section_2, and tomcat does not include all the same kinds of support
that the Liberty server does. For these reasons, and because tomcat is an extremely
lightweight server, we'll see it will start a bit faster than Liberty and it will
be using less memory after startup. In later sections of the workshop, we'll further
improve on these numbers by using IBM Semeru Runtimes and its shared classes cache
technology.

We'll be using Tomcat v10 to stay with Java 17 consistently through the entire
workshop.

Let's get started!

We'll be starting with the pre-built sample.war file provided by the tomcat community.

1. Build a tomcat container that contains the sample application. There is
a Dockerfile.tomcat_temurin file provided that copies the sample.war file into a
standard Tomcat container that is built using the Eclipse Temurin JDK distribution.
Eclipse Temurin is a straight JDK built from the source code released by the
OpenJDK project (so it uses the HotSpot JVM).

Run the following command:

	$ podman build --network=host -f Dockerfile.tomcat_temurin -t tomcat_temurin

3. Run the container. It will automatically start the Tomcat server with the
sample application. Run the following command:

	$ podman run --cpus=1 --network=host --name=tomcat_temurin --replace -it tomcat_temurin > log.cpu1

This starts tomcat using only a single CPU core and stores the output into the file log.cpu1.

4. (Ignore steps 4 if you already have podman stats running in another terminal window)
Go to another terminal window and log into the workshop container. Run the following command
in another terminal window:

	$ podman exec --privileged -it workshop-main /bin/bash

This will connect to the running workshop container so that you can run another command there
while the tomcat server is running.  Use podman stats to observe the memory use of the container:

	$ podman stats

5. Review the memory use of the server

The podman stats command shows various statistics about all containers running within the main
workshop container. For example, you should see something like:

	ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	671f11639e46  tomcat_temurin     0.32%       67.28MB / 2.047GB  3.29%       0B / 0B          0B / 0B     31          1.25609s    7.83%

which shows the Tomcat server you started in step 3 running with 67MB of memory. Tomcat is a
lightweight server but less capabilities are loaded here than into the Liberty server you started
in Sections 1 and 2, which explains at least part of the different in memory usage.

You can leave the podman stats command running for step 6.

6. Hit control-C to stop the server.

Press Control-C to stop the server. At this point, we can run the startupTime.awk script on the
log to calculate the time it took from initiating the java command line from catalina.sh until
the server posted its "Server started" message.

	$ ./startTime.awk log.cpu1
	Server initiated 1715355700320533504, up at 1715355701473000000
	Full start time is 1152.47 ms

So the server started in roughly 1.15 seconds.

7.  You can start the server a few more times, capturing the output to different log files so that
you can get the start time for several runs, just to see the variation you experience. We aren't going
to do a rigourous statistical analysis for this workshop but that would obviously be important if you
were going to start measuring server start time for your production workloads.

You can also run with more cores just to see how the start time changes. For example:

	$ podman run --cpus=2 --network=host --name=tomcat_temurin --replace -it tomcat_temurin > log.cpu2
	<Hit Control-C after checking the memory consumption in the stats output>
	$ ./startTime.awk log.cpu2
	Server initiated 1715356179088315648, up at 1715356179722000000
	Full start time is 633.684 ms

As you can see, adding a second core helps reduce the startup time to 633ms, but you may also find
that the memory consumption increases a bit (perhaps to 73MB).

8. You're done! 

This completes the third section in the workshop!

You should have measured performance somewhat along these lines:

JDK		Core limit	Start time	Memory usage after start
Temurin		1 core		1152.47ms	68MB
Temurin		2 cores		633.684ms	73MB

Move on to the next section to see what happens when we move to an IBM Semeru Runtimes JDK to run
the Tomcat server with the same sample application.
