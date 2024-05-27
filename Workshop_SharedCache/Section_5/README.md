Section_5

In this section of the workshop, we're going to try to use the Semeru Runtimes
shared classes cache technology to accelerate the less than inspiring startup
times we saw in the last section when we tried to start the Tomcat server
with IBM Semeru Runtimes.

For consistency, we'll be using Tomcat v10 and Java 17 through the entire
workshop.

Let's get started!

1. Build a tomcat container that contains the sample application. There is
a Dockerfile.tomcat_semeru.scc file provided that first copies the Semeru Runtimes
JDK into the container and then copies the sample.war file. Finally, it makes
sure that the shared classes cache will be used by setting
the environment variable OPENJ9_JAVA_OPTIONS=-Xshareclasses . Using this option
is the simplest way to ensure the shared classes technology is activated. But
you're going to see that the results will be unexpected using this overly
simplistic approach.

Sidebar: This environment variable will only be read by the Eclipse OpenJ9 JVM
that's in Semeru Runtimes, so the fact that this command-line option wouldn't be
recognized by HotSpot shouldn't be a concern if you want to be able to run either
JVM (because HotSpot will never look at this environment variable). Using this
approach makes it easier for the same Tomcat configuration to be used to start a
Tomcat server with either a HotSpot-based distribution like Eclipse Temurin or an
OpenJ9-based distribution like IBM Semeru Runtimes.

Run the following command to build the container:

	$ podman build --network=host -f Dockerfile.tomcat_semeru.scc -t tomcat_semeru.scc

3. Run the container. It will automatically start the Tomcat server with the
sample application. Run the following command and wait for the server to start:

	$ podman run --cpus=1 --network=host --name=tomcat_semeru.scc --replace -it tomcat_semeru.scc > log.cpu1

As in earlier sections, we're initially confining the server to start with just 1 CPU core.

4. (Ignore step 4 if you already have podman stats running in another terminal window)
Go to another terminal window and log into the workshop container. Run the following command
in another terminal window:

	$ podman exec --privileged -it workshop-main /bin/bash

This will connect to the running workshop container so that you can run another command there
while the tomcat server is running. Use podman stats to observe the memory use of the container.
	$ podman stats

5. Review the memory use of the server

This command shows various statistics about all containers running within the main workshop
container. For example, you should see something like:

	ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	e564779194b2  tomcat_semeru.scc  0.57%       39.33MB / 2.047GB  1.92%       0B / 0B     8.192kB / 0B  35          5.275247s   45.62%

As you can see, IBM Semeru Runtimes runs in even less memory than earlier (39MB versus the 42MB
we saw earlier in Section_4). That's not as dramatic an improvement as we saw with the Liberty
server, but let's ignore that fact for now. With this new memory footprint baseline, the Temurin
JDK with the HotSpot JVM consumes 75% more memory to start the server.

6. Hit control-C to stop the server.

Once you stop the server, we can check the start time using the startTime.awk script:

	# ./startTime.awk log.cpu1
	Server initiated 1715357831549004032, up at 1715357834783000000
	Full start time is 3234 ms

Wow, what is going on here? That's already much slower than starting with Temurin and even
slower than using Semeru Runtime without their (in?)famous shared cache technology! What's
going on here?

7. Do a few runs to confirm your finding and that it's not just a fluke. You may see some
variation because the times are much longer, but you should find the times are consistently
large to a wildly unexpected degree.

Sidebar: ask yourself what you would do at this point if had gone through this exercise outside
	of this workshop on your own. Maybe this kind of result has even happened to you already.
	Would you continue to try to understand why the startup time got worse? Or would you give
	up, assuming that Semeru Runtimes reputation for fast startup is probably exaggerated
	or undeserved?

8. I'm afraid you've been set up. Let's consider how the shared cache technology works. In order
to have fast startup time, you need a cache to help you go faster. That means you need to do one
"cold" run to populate the cache with classes and compiled code. This "cold" run is expected to
run more slowly because its purpose is to generate a high quality cache that will enable
subsequent "warm" runs to start as quickly as possible. In fact, the Eclipse OpenJ9 JVM employs
very different compilation heuristics in this cold run compared to even a normal run that
doesn't use the shared classes cache, and that's why the start time you saw in Step 6 was
even longer than the times we measured in the previous section when we weren't using the
shared classes cache.

So what happened in Step 1 is that all we did in the Dockerfile.tomcat_semeru.scc is to add the
-Xshareclasses option. There is no cache in the container so the starting point for every
run we did in steps 3 is to populate a new cache that's just going to be thrown away
when the container stops (because by default results aren't persisted when a container runs) !
Basically, we turned every run into a "cold" run that starts more slowly by design so
that it builds a high quality cache.

How do we fix it? Rather than just turning on -Xshareclases when we run the server, we need to
actually start the server inside the build step to create a prepopulated cache. Once the cache
is created in the build step, it will be present every time the container is run and every one
of those runs will be a "warm" run that will start faster. To populate the cache with tomcat, we can
start the tomcat server, sleep for a while until we're sure the server is started, then stop the
server. You can see this at the end of Dockerfile.tomcat_semeru.prepop_scc . Let's build that
container now:

	$ podman build --network=host -f Dockerfile.tomcat_semeru.prepop_scc -t tomcat_semeru.prepop_scc .

If you pay very close attention, you'll see one more thing that's done at the very end of
Dockerfile.tomcat_semeru.prepop_scc : we added a "readonly" suboption to -Xshareclasses.
Since nothing written into the cache in a "warm" run will be saved by the container anyway,
there is no point adding any other classes or compiled code after the build step. By updating
the option to include "readonly", all accesses to the cache do not need synchronization and
all the code paths that focus on adding to the cache will be disabled. The end result will
be faster startup!

Let's see how it works out by starting one of the new containers with the usual one CPU core:
	$ podman run --cpus=1 --network=host --name=tomcat_semeru.prepop_scc --replace -it tomcat_semeru.prepop_scc > log.prepop.cpu1

There is a memory improvement because the shared cache is now being used:

	ID            NAME                      CPU %   MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	3e4994b07276  tomcat_semeru.prepop_scc  0.84%   35.94MB / 2.047GB  1.76%       0B / 0B     8.192kB / 0B  35        719.773ms   5.87%

And if we look at the start time:
	$ ./startTime.awk log.prepop.cpu1
	Server initiated 1715359356618435584, up at 1715359357211000000
	Full start time is 592.564 ms

Now that's more like it! You can do the same runs with 2 cores:
	$ podman run --cpus=2 --network=host --name=tomcat_semeru.prepop_scc --replace -it tomcat_semeru.prepop_scc > log.prepop.cpu2

And see almost exactly the same memory usage:
	ID            NAME                      CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	3adfe1f7ded9  tomcat_semeru.prepop_scc  0.97%       35.91MB / 2.047GB  1.75%       0B / 0B     0B / 0B     36          718.876ms   6.49%

With even faster start time (under half a second!):
	$ ./startTime.awk log.prepop.cpu2
	Server initiated 1715359654960000256, up at 1715359655408000000
	Full start time is 448 ms

9. This is the last section of this part of the workshop, so you can stop the podman stats command
running in the other terminal window at this point by hitting control-C that window.

9. You're done! 

In this section, we initially found very poor results due to a fairly common mistake activating
the shared cache technology in Semeru Runtimes that seemed to paint a very dim picture. But when
we properly configured the shared classes cache and prepopulated the cache in the container build
step, we saw dramatically better startup and memory use with Semeru Runtimes. When running with
a single CPU core, we found that compared to using Semeru Runtimes, the Temurin JDK will consume
88% more memory (68MB versus 36MB) and will start 94% slower (1152ms versus 593ms).

Let's add the numbers to our performance summary table:
JDK			Core limit	Start time	Memory usage after start
Temurin			1 core		1152.47ms	68MB
Semeru NOSCC		1 core		1977.13ms	42MB
Semeru SCC		1 core		3234ms		39MB
Semeru Prepop SCC	1 core		593ms		36MB

Temurin			2 cores		633.684ms	73MB
Semeru NOSCC		2 cores		1148.12ms	42MB
Semeru SCC		2 cores		1624.24ms	39MB	# bonus: collect this data point yourself!
Semeru Prepop SCC	2 cores		448ms		36MB

We hope you enjoyed this workshop and learned more about how startup time and memory usage
can be dramatically different depending on which JDK you use to deploy your Java workloads.
You have also seen the most common misconfiguration of Semeru Runtimes's shared cache
technology that results in much slower start-up times that may lead developers to the wrong
conclusions about the worth of this technology. In the end, properly configuring the shared
class cache technology, particularly when using containers, can led to dramatic savings in
both start time and memory use. Faster start time means you can provide a more responsive
and elastic infrastucture, whereas lower memory usage can translate into smaller VMs which
cost less money.

This completes the fifth and final section in the workshop! Great work!
