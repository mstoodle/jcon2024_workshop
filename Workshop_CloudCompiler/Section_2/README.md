Section_2

In this section, we're going to extend on the baseline we ran in
the last section. We're doing to deploy the same JakartaEE8 application
(AcmeAir), which simulates a flight reservation system, with OpenLiberty
and Semeru Runtimes. But in this section, we will also deploy
a Semeru Cloud Compiler (SCC), which will perform all the JIT compilation
work in a separate container that can be given resources specific
to the needs of the JIT. That means that the JVMs connected to the
SCC also need only be given resources specific to the needs of the
application workload.

Before you follow the steps below, be sure that you have created the
containers that are to be used by going to the ../containers directory
and running the all.build.sh script.

1. Create four windows in the workshop-main container

You will need the mongo, jitserver, acmeair, and jmeter containers in 
this section. Tou will also need a total of four terminal windows that
are all running inside the workshop-main container. You can use the
main one (the podman run command) as is, but you'll need three more.
For each new terminal window you need, run the following command:

	$ podman exec --privileged -it workshop-main /bin/bash

This will start a new shell process inside the workshop-main container.
From there, change to the directory containing these instructions:
$ cd /Workshop_CloudCompiler/Section_2. You should now have four
terminal windows, let's call them Window1, Window2, Window3, and
Window4.  You'll find three directories under Section_2 called Window1,
Window2, and Window3 (we'll cover Window4 in a moment). In one window,
change to the Window1 directory (and we'll now refer to this as
"Window1"). In one of the others, change to the Window2 directory
(and we'll now call this one "Window2"). Do the same for Window3,
which we'll predictably call "Window3". Finally, the fourth window
we'll call, you guessed it, "Window4").

2. Start podman stats in Window4

In Window4, you will only run one command to monitor the containers
started in this workshop. Run the command:
[Window4]	$ podman stats

This command will update every few seconds with details of all the
containers running in the other windows, showing the %CPU and
memory usage.

3. Start mongdb in Window1

Switching focus to Window1, you will first start the mongo container
by running
[Window1]	$ ./step1_start.mongo.sh

This command ensure the mongo database container is running and
refreshes the database content to a known fresh state (for
reliable benchmarking runs).

4. Start the jitserver in Window1

The second thing we'll do in Window1 is to get the cloud compiler
up and running. Eclipse OpenJ9 calls this a "JIT server" so we've
called our container "jitserver" too. Start this container with
the following command in Window1:

[Window1]	$ ./step2_start.jitserver.sh

The jitserver starts almost immediately and is ready to go. You'll
notice that, although the jitserver can run as a daemon container,
we're not doing that for this workshop so you can see it in action.

If you want to look more closely at what runs in this container,
you can take a quick trip up to ../../containers to inspect the
jitserver.Dockerfile . What you'll see is that this container
really is just a Semeru Runtimes Open Edition container where
the container entry point runs a single command that's in the
JDK's bin directory: the "jitserver" command. That's it!
So every Semeru Runtimes JDK that supports running the cloud
compiler has this tool available anywhere you can run 'java'.

5. Start the AcmeAir application in Window2

We're going to hop over to Window2 now to start the AcmeAir container.
This container loads and initializes the AcmeAir application to make
it ready to accept load. Unlike how we ran it in the previous
section, however, this time the container will be configured
to connect to the jitserver container over in Window1. Before we
start this container, let's take a quick look at how that works.

All the magic is contained in the step3_start.acmeair.sh script,
which is small enough that you can just cat the file:

[Window2]	$ cat step3_start.acmeair.sh

You'll see that this container sets up a couple of environment
variables like JITSERVER_HOST and JITSERVER_OPTS . Otherwise
it's using the same AcmeAir container we built earlier that doesn't
use the Cloud Compiler. That's a nice feature because it means you
don't have to rebuild your containers to take advantage of 
remote JIT compilation. You just need to pass some options to
the running JDK. The key ones are listed in JITSERVER_OPTS:

	-XX:+UseJITServer tells the JDK to try to connect to a JIT server
	-XX:JITServerAddress is the IP address to connect to the JIT server
	-XX:JIIServerPort is the port to use to connect to the JIT server

In this example, the IP address is simply "localhost" and the
port is only specified for completeness (38400 is the default port
but it could have been configured to a different value using this
same option on the "jitserver" command we learned about earlier
in step 3.

The command that starts the AcmeAir container is also mostly
unmodified: all it does is pass the ACMEAIR_OPTS options (which
are set to the JITSERVER_OPTS) in as JVM_ARGS, which is a variable
the Liberty server will use. Other servers may allow you to pass
Java options in via other environment variables, or you can also
pass these options directly in  OPENJ9_JAVA_OPTIONS.

The last thing to note is that this AcmeAir instance will only
be allowed to run with 1 CPU core and to use 400MB of memory.

Start the AcmeAir container now:

[Window2]	$ ./step3_start.acmeair.sh

This starts the acmeair_jitserver container. If you look at
Window1 after starting this container, you'll see a message
indicating a JVM client has connected to the server. It should
look something like:

	#JITServer: t= 13943 A new client (clientUID=1309130167419053808) connected. Server allocated a new client session.

You should also see some CPU activity in Window4 for the jitserver
container as it starts compiling methods needed to load and
initialize the OpenLiberty and the AcmeAir application.

6. Stop the jitserver (!)

We're going to demonstrate the resilience of the
Semeru Cloud Compiler now. Hit Control-C in Window1 to
stop the jitserver container. It should stop almost
immediately. Notice, however, that the AcmeAir application
is still running in Window2. Losing the JIT server did
not affect the JVM client that was connected to it.

Let's make a quick change to how the jitserver container
is run so we get a better visual impression that the
jitserver is doing work. In Window1, take a quick
peek at step4_start.jitserver_verbose.sh :

[Window1]	$ cat step4_start.jitserver_verbose.sh

If you compare this file to what you saw earlier, there
is only one difference. Rather than running just the
jitserver command, this script will also pass in an
option via the environment variable OPENJ9_JAVA_OPTIONS:
	OPENJ9_JAVA_OPTIONS=-Xjit:verbose={compilePerformance}

This is not an option that's specific to the cloud compiler;
you can use this option even with regular java runs, but it's
usually used along with an option to store the log into a file
rather than printing on the console as we're doing in this
example.

So we're expecting to see JIT compilations happening
in the jitserver once a client connects to it. Start the
container by running the script:
[Window1]	$ ./step5_start.jitserver_verbose.sh

Not much may happen right away, but eventually the AcmeAir
container will notice that the cloud compiler is live again
and it will connect and perform compiles there. If you don't
see anything, don't worry about it. In the next step we're
going to drive load against AcmeAir which will force more
compilations to happen and that will be quite obvious!

7. In Window3, drive load to AcmeAir

Let's switch our focus on Window3. Before you start the
jmeter container, you may want to arrange your windows
so that you can see the podman stats in Window4, the
last few lines of Window1 so you can see if any JIT
compilations are happening there, and Window3 should
have the focus. The output on Window2 won't be too
interesting, so you don't have to worry about keeping
it visible unless you want to. 

Let's start the load! Run the following command:
[Window3]	$ ./step5_start.jmeter.sh

You should immediately see compilations start to fly
by in Window1 at the jitserver.  The view in Window3 will
show the performance of the AcmeAir container as
observed by the load driver (jmeter).

Since this jmeter container also does not run as a daemon and so
will produce output. Every few seconds, it will display a pair of
lines: 1) the first line shows measurements for the transactions
it has initiated since the last output was generated, and 2) the
second line shows the aggregated performance measurements since
the beginning of the run. This output looks slightly confusing
because it looks like very high throughput occurs but then a much
lower number comes out. The first number can be thought of as the
instantaneous performance experienced by transactions that
are arriving "now" whereas the second one reflects the overall
performance of the server since load was first applied. You
should see the instantaneous throughput number improving over
time. Once you see the number starting to level off (which
will probably take a few minutes), the server will be fully
warmed up and you may see the JIT compiler output in Window1
start to slow down. While the server is ramping up, you may
also want to periodically watch the podman stats output in
Window4 to see if you can see the high memory use that
periodically happens as the JIT is compiling big methods.

This is a large application being forced to run in a single
CPU core so it takes a while to ramp up, but hopefully
within a minute or so you'll see the peak instantaneous
throughput reached. On my machine, it looked something
like this:

	summary +  17392 in 00:00:04 = 4873.1/s Avg:     0 Min:     0 Max:    40 Err:    39 (0.22%) Active: 0 Started: 4 Finished: 4

The data points that followed showed similar level of throughput (4873 /s).

Once you're happy you've seen the peak throughput, hit Control-C
in both Window2 (AcmeAir) and Window3 (jmeter). Once AcmeAir stops,
you should see a message in Window1, something like:

	#JITServer: t=258537 Client (clientUID=17798379140941681213) disconnected. Client session deleted

The JIT server goes back to wait for other clients to connect to it.

8. Can we reduce the memory now?

If the JIT server is covering all the JIT memory requirements,
let's see if we can run AcmeAir with less memory. Back in Window2,
there is a last script to try (step6_start.acmeair.200mb.sh), but
let's take a look at what's changed from step3:

	$ diff step3_start.acmeair.sh step6_start.acmeair.200mb.sh
	< podman run --replace --network=host -e JVM_ARGS="$ACMEAIR_OPTS"   -m=400m --cpus=1 -v $PWD/mongo.properties:/config/mongo.properties --name acmeair_jitserver_400mb $ACMEAIR_IMAGE
	---
	> podman run --replace --network=host -e JVM_ARGS="$ACMEAIR_OPTS"   -m=200m --cpus=1 -v $PWD/mongo.properties:/config/mongo.properties --name acmeair_jitserver_400mb $ACMEAIR_IMAGE

The only difference there is the memory limit: in the step6 script,
we're reducing the memory limit for AcmeAir to only 200mb. That's even
smaller than the memory (225mb) where the AcmeAir server was unable to
function effectively in Section_1 of this workshop! Given this application
is a signficant JakartaEE application, it will be pretty impressive to run
it effectively in a container with only 1 CPU core and 200mb of memory.
Let's see how it does!

From Window2, start the lower memory server:

[Window2]	$ ./step6_start.acmeair.200mb.sh

Then you can jump back to Window3 and restart the exact same jmeter
script we used earlier:

[Window3]	$ ./step5_start.jmeter.sh
(if you really want to be a rigourous and careful performance engineer, you
could start back from the beginning by restarting the mongo and jitserver
containers running in Window1, but for this exercise we can just leave them
running as-is).

Once you start the jmeter load driver, you'll see the performance
rampup and you should see the instantaneous throughput reach
basically the same level as we saw earlier when AcmeAir was
able to use 400mb.  Amazing!

You won't always be able to cut the size of the container in half
(and you may be wondering where 400mb came from originally...it's
basically the memory that a HotSpot based JDK will need in order
to reach similer throughput levels), but reducing container memory
requirements means more containers will fit on a single machine
instance. And those savings add up in Kubernetes (OpenShift)
deployments where you'll see more pods able to fit onto an existing
node, and that fewer nodes will be needed to run a large number of pods.

Bonus experiments

In the containers directly, you'll see that multiple AcmeAir server
containers were created to listen on different ports. Try to set up
multiple AcmeAir containers to run in parallel (you'll also have to
start multiple jmeter containers to drive load at the different
AcmeAir servers). You can connect those servers to the same jitserver
instance and see whether how much aggregate load you can process with
the overall 400mb memory limit (i.e. if you have two containers that
each have 1cpu and are limited to 200mb of memory, your total memory
requirement is 400m). You should be able to handle substantially more
laod with two small containers than you can with one large one. How
does it compare if you give the large one 2 CPU cores? How expensive
do you think it will be to deploy many smaller containers on a small
VM than larger containers? Which approach is more cost effective to
handle a given level of incoming load? Alternatively, what's the
highest load you can achieve with smaller containers versus one
large container for a given VM?

9. That's it!

In this section, you saw how using a separately (but easily!) configured
JIT server (the Semeru Cloud Compiler) effectively offloads both
CPU and memory requirements of the JIT compiler so that your servers
only have to process the transactions that run your business. You
saw how using a JIT server enable the server process (which can be any
microservice) to run in much less memory, which could save deployment
costs by running more services on a single VM instance or by using
smaller, less expensive, VM instances.

You've now reached the end of the workshop! Well done!
