Section_1

In this workshop, we're going to look at using the Semeru Cloud Compiler
to offload JIT compilation resources from client JVMs so that the Java
application does not see the intensive memory and CPU demands with the
JIT compiler is actively compiling code.

In this first section, we're going to establish a baseline by deploying
a JakartaEE8 application called AcmeAir, which simulates a flight
reservation system, with OpenLiberty and Semeru Runtimes. We won't
initially use the Semeru Cloud Compiler. To keep things simple, this
is a monolithic application which makes it easier to start and stop.
But hopefully through the workshop, you'll see how it shouldn't be much
more difficult to configure multiple microservices to run the same way.

Since we're going to be driving load to this application, the setup
is a little more complicated than in the other workshops where we just
started the server but didn't really ask it to do anything. The
AcmeAir application relies on a Mongo database and the simulated
reservation load will be driven by JMeter.

Before you follow the steps below, be sure that you have created the
containers that are to be used by going to the ../containers directory
and running the all.build.sh script.

1. Create your windows
You will need the mongo, acmeair, and jmeter containers, and you will
need three terminal windows that are both running inside the workshop-main
container. You can use the main one as is, but so you'll need two more.
For each new terminal window you need, run the following command:

	$ podman exec --privileged -it workshop-main /bin/bash

This will start a new shell process inside the workshop-main container.
From there, change to the directory containing these instructions:
$ cd /Workshop_CloudCompiler/Section_1. You should now have three
terminal windows, let's call them Window1, Window2, and Window3.
You'll find two directories under Section_1 called Window1 and
Window2 (we'll cover Window3 in a moment). In one window, change to
the Window1 directory (and we'll now refer to this as "Window1"). In
one of the others, change to the Window2 directory (and we'll now
call this one "Window2"). Predictably, we'll call the remaining
window "Window3".

2. Start podman stats in Window3

In Window3, you will only run one command to monitor the containers
started in this workshop. Run the command:
	$ podman stats

3. Start containers in Window1

Switching focus to Window1, you will first start the mongo container
by running
	$ ./step1_start.mongo.sh

This command ensure the mongo database container is running and
refreshes the database content to a known fresh state (for
reliable benchmarking runs).

The second thing we'll do in Window1 is to start the AcmeAir container
which will load and initialize the AcmeAir application to make it ready
to accept load. Unlike the other containers we've started in the workshops,
we will not be running this container as a daemon so its output will
come out in the window (and there will be a lot of it!).

	$ ./step2_start.acmeair.sh

This starts a container called acmeair_baseline. You should see
a dramatic amount of output being produced in this window, because
this container starts the Semeru Runtimes JDK with this option:
	-Xjit:verbose={compilePerformance}

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
