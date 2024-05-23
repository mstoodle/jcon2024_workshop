Section_1

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

You may want to make this window wide but it probably only needs
a few lines because we won't be running a lot of containers at the
same time.

3. Start containers in Window1

Switching focus to Window1, you will first start the mongo container
by running
[Window1]	$ ./step1_start.mongo.sh

This command ensure the mongo database container is running and
refreshes the database content to a known fresh state (for
reliable benchmarking runs).

The second thing we'll do in Window1 is to start the AcmeAir container
which will load and initialize the AcmeAir application to make it ready
to accept load. Unlike the other containers we've started in the workshops,
we will not be running this container as a daemon so its output will
come out in the window (and there will be a lot of it!).

[Window1]	$ ./step2_start.acmeair.sh

This starts a container called acmeair_baseline_400m with, you guessed it
a container memory limit of 400MB and one CPU core. It doesn't start the server
as a daemon so that you can see the output along with the server startup time:

	The defaultServer server started in 3.214 seconds.

Once the server has started, take a look at Window3 at the
podman stats and you'll see that this server uses about 80MB of
memory after starting :

ID            NAME                   CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO           PIDS        CPU TIME     AVG CPU %
423dc558c688  acmeair_baseline_400m  4.23%       79.6MB / 419.4MB   18.98%      0B / 0B     8.192kB / 0B       47          5.836339s    12.82%



3. Start the load

The next step of this section will be in Window2, so switch your
focus over there now. Now we're going to start driving load to
the AcmeAir application to see the effect. Run this command:

[Window2]	$ ./step3_start.jmeter.sh

This container also does not run as a daemon and so will produce
output. Every few seconds, it will display two lines: 1) the first
line shows measurements for the transactions it has initiated
since the last output was generated, and 2) the second line
shows the aggregated performance measurements since the beginning
of the run. This output looks slightly confusing because it
looks like very high throughput occurs but then a much lower
number comes out. The first number can be thought of as the
instantaneous performance experienced by transactions that
are arriving "in the moment" whereas the second one reflects
the overall performance of the server since load was first
applied. You should see the instantaneous throughput number
improving over time. Once you see the number starting to level
off (which will probably takes about a minute), the server will
be fully warmed up.  While the server is ramping up, you may
also want to periodically watch Window3 to see if you can
see the high memory use that periodically happens as the JIT
is compiling big methods. This server is only allowed to use a
single CPU core, so it takes a while to ramp up and also the
transactions have to share that single core and the memory with
all the CPU and memory demands of the JIT compiler.

5. Stop the containers

When you have gotten your fill of watching the activity of
this server, you can stop it by pressing Control-C in
Window1, which should stop the acmeair_baseline_400m container.
That should also stop the jmeter container in Window2, but if
it doesn't, you can run this command to eventually stop it:

[Window1]	$ podman stop jmeter

6. Let's try that again...

In the previous experiment, the container memory limit we
used for AcmeAir was 400MB, and that is a comfortable enough
limit for the AcmeAir server that the activities of the JIT
compiler are not compromised. The server ramps up smoothly
and reaches the peak performance it is capable of.

Let's try it one more time but with a lower memory limit:
this time we're going to run in just 225MB to see how it
does.

Repeat the earlier steps to start the smaller container:

[Window1]	$ ./step4_start.acmeair225.sh

This container will start in about the same time as the
earlier server, and it will use about the same amount
of memory after starting.

Now we're going to try to apply load against this server,
just like we did before in Window2:

[Window2]	$ ./step5_start.jmeter.sh

Here you should observe a very big difference. Not only
will the server ramp up much more slowly than before,
you may even see the server crash because all the 
memory available to the container is consumed and we
haven't configured any swap space.

If the server doesn't crash, you should see that the
overall performance is lower and it takes longer to
get to the peak performance. In fact, you may see the
performance drop markedly as the JIT compiler workload
dominates the ability of the server to process
transactions.

Whenever you want to stop, you can hit Control-C in Window1
and that should stop both the AcmeAir server as well as the
jmeter container.

You can stop the mongo container too at this point, if you
would like:

	$ podman stop mongodb

That's it for the first section!  In the next section, we'll
be looking at how to add the Semeru Cloud Compiler into the
mix.
