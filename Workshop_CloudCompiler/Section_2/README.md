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
	$ podman stats

This command will update every few seconds with details of all the
containers running in the other windows, showing the %CPU and
memory usage.

3. Start mongdb in Window1

Switching focus to Window1, you will first start the mongo container
by running
	$ ./step1_start.mongo.sh

This command ensure the mongo database container is running and
refreshes the database content to a known fresh state (for
reliable benchmarking runs).

4. Start the jitserver in Window1

The second thing we'll do in Window1 is to get the cloud compiler
up and running. Eclipse OpenJ9 calls this a "JIT server" so we've
called our container "jitserver" too. Start this container with
the following command in Window1:

	$ ./step2_start.jitserver.sh

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

	$ cat step3_start.acmeair.sh

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

	$ ./step3_start.acmeair.sh

This starts the acmeair_jitserver container. If you look at
Window1 after starting this container, you'll see a message
indicating a JVM client has connected to the server. It should
look something like:

	#JITServer: t= 13943 A new client (clientUID=1309130167419053808) connected. Server allocated a new client session.

You should also see some CPU activity in Window4 for the jitserver
container as it starts compiling methods needed to load and
initialize the OpenLiberty and the AcmeAir application.

6. Stop the jitserver (!)

We're going to hopefully demonstrate the resilience of the
Semeru Cloud Compiler now. Hit Control-C in Window1 to
stop the jitserver container. It should stop almost
immediately. Notice, however, that the AcmeAir application
is still running in Window2. Losing the JIT server did
not affect the JVM client that was connected to it.

Let's make a quick change to how the jitserver container
is run so we get a better visual impression that the
jitserver is doing work. In Window1, take a quick
peek at step4_start.jitserver_verbose.sh :

	$ cat step4_start.jitserver_verbose.sh

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
	$ ./step5_start.jitserver_verbose.sh

Not much may happen right away, but eventually the AcmeAir
container will notice that the cloud compiler is live again
and it will connect and perform compiles there. If you don't
see anything, don't worry about it. In the next step we're
going to drive load against AcmeAir which will force more
compilations to happen.

7. In Window3, drive load to AcmeAir

Let's switch our focus on Window3. Before you start the
jmeter container, you may want to arrange your windows
so that you can see the podman stats in Window4, the
last few lines of Window1 so you can see if any JIT
compilations are happening there, and Window3 should
have the focus. The output on Window2 won't be too
interesting, so you don't have to worry about keeping
it visible unless you want to. 

Let's start the load! Run the following command in
Window4:
	$ ./step5_start.jmeter.sh

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
we're reducing the memory limit for AcmeAir to only 200mb. Given
this application is a signficant JakartaEE application, it will be
pretty impressive to run that effectively in a container with
only 1 CPU core and 200mb of memory. Let's see how it does!

From Window2, start the lower memory server:

	$ ./step6_start.acmeair.200mb.sh

Then you can jump back to Window3 and restart the exact same jmeter
script we used earlier:

	$ ./step5_start.jmeter.sh
(if you really want to be a good performance engineer, you could start
back from the beginning by restarting the mongo and jitserver containers
running in Window1, but for this exercise we'll just leave them as-is).

Once you start the jmeter load driver, you'll see the performance
rampup and you should see the instantaneous throughput reach
basically the same level as we saw earlier when AcmeAir was
able to use 400mb.

You won't always be able to cut the size of the container in half
(and you may be wondering where 400mb came from originally...it's
basically the memory that a HotSpot based JDK will need in order
to reach similer throughput levels), but reducing container memory
requirements means more containers will fit on a single machine
instance. And those savings add up in Kubernetes (OpenShift)
deployments where you'll see more pods able to fit onto a node,
or that fewer nodes will be needed to run a large number of pods.

9. That's it!

You've reached the end of the workshop! Well done!




3. Watch the JIT compiler go!

Since there's no log file specified (you would see ,vlog=<filename>)
in this option, the output is generated to the terminal window.
You don't need to understand all this output for this workshop, but
know that the majority of the output produced is a line of text
describing each new method that is compiled by the JIT compiler
while running the application. After a while, things will slow
down and, if you wait long enough, it will probably mostly stop.
If you can find acmeair_baseline in the stats output of Window3,
its %CPU will drop to low single digits once the server finalizes
the JIT compiles. Try to wait for the compilation output to settle
down, but if you are impatient, you can start driving the load
once the server is started, which should only take a few seconds.

4. Start the load

The next step of this section will be in Window2, so switch your
focus over there now. Now we're going to start driving load to
the AcmeAir application to see the effect. I suggest arranging
your windows so that you can see some of the lines of Window1
underneath Window2, and so that you can see the podman stats
output in Window3. Window 2 will be in the foreground. Once 
you have the windows arranged as you like, run this command:

	$ ./step3_start.jmeter.sh

This container also does not run as a daemon and so will produce
output. Every few seconds, it will display two lines: 1) the first
line shows measurements for the transactions it has initiated
since the last output was generated, and 2) the second line
shows the aggregated performance measurements since the beginning
of the run. This output looks slightly confusing because it
looks like very high throughput occurs but then a much lower
number comes out. The first number can be thought of as the
instantaneous performance experienced by transactions that
are arriving "now" whereas the second one reflects the overall
performance of the server since load was first applied. You
should see the instantaneous throughput number improving over
time. Once you see the number starting to level off (which
will probably take a few minutes), the server will be fully
warmed up and you may see the JIT compiler output in Window1
start to slow down. While the server is ramping up, you may
also want to periodically watch Window3 to see if you can
see the high memory use that periodically happens as the JIT
is compiling big methods. This server only has a single core,
so it takes a while to ramp up and also the transactions have
to share that single core with all the CPU demands of the
JIT compiler.

5. Stop the containers

When you have gotten your fill of watching the activity of
this server, you can stop it by pressing Control-C in
Window1, which should stop the acmeair_baseline container.
That may also stop the jmeter container in Window2, but if
it doesn't, you can run this command to eventually stop it:

	$ podman stop jmeter1

You can stop the mongo container too at this point, if you
would like:

	$ podman stop mongodb

Bonus: Create a second acmeair container and a second jmeter
container that can run at the same time as the ones described
in this section. You'll see that both acmeair containers
perform tremendous amounts of JIT compilation.

That's it for the first section!  In the next section, we'll
be looking at how to add the Semeru Cloud Compiler into the
mix.
