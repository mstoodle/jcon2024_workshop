Section_3

In this section of the workshop, we'll be running the Liberty server using the Liberty/Semeru
InstantOn technology to save a checkpointed Liberty server using the beforeAppStart checkpoint.
We'll find that the server starts much faster even than the Liberty server using the shared
classes cache.

1. Build the getting started application

	$ mvn package

2. Build an OpenLiberty container that contains the getting started application. There is
a Dockerfile.liberty_beforeappstart file provided that builds the container and also
starts the Liberty server before issuing the beforeAppStart checkpoint.
Run the following command:

	$ podman build \
	    --network=host \
	    -f Dockerfile.liberty_beforeappstart \
	    --no-cache \
	    -t liberty_beforeappstart \
	    --cap-add=CHECKPOINT_RESTORE \
	    --cap-add=SYS_PTRACE \
	    --cap-add=SETPCAP \
	    --security-opt seccomp=unconfined \
	    .

Notice that the last step that runs in this build command is the checkpointing step. This
command is added to the usual Dockerfile:
	RUN checkpoint.sh beforeAppStart

That's it! That's all you have to do to create a Liberty container that uses the InstantOn
beforeAppStart checkpoint!

3. Run the container. It will automatically start the OpenLiberty server by restoring the
saved checkpoint and then completing the server startup (i.e. loading applications).
Run the following command and wait for the server to start:

	$ podman run \
	       --cpus=1 \
	       --network=host \
	       --cap-add=CHECKPOINT_RESTORE \
	       --cap-add=SETPCAP \
	       --name=liberty_beforeappstart \
	       --replace \
	       liberty_beforeappstart

Notice that restoring the process does *NOT* require the --security-opt seccomp=unconfined. This
option is needed to prepare the checkpoint (which would normally happen in your CI system) but
is not needed to start the server (which happens in your production system).

Look for the elapsed time to start the server. You'll see a line that ends with something like::
	The defaultServer server started in 0.517 seconds.

Without using a checkpoint, the Liberty start time with one core was 2.917 seconds.
The beforeAppStart checkpoint enable Liberty to start in 18% of the time. Put another
way, if you don't use the beforeAppStart checkpoint, the Liberty server will take
approximately 5.6X longer to start! If you use Temurin, it will take 10.7X longer to start!

4. (Ignore step 4 if you already have podman stats running in another terminal window)
Go to another terminal window and log into the workshop container. Run the following command
in another terminal window:
	$ podman exec --privileged -it workshop-main /bin/bash

This will connect to the running workshop container so that you can run another command there
while the Liberty server is running. Run podman stats to observe the memory use of the container.
	$ podman stats

5. Review the memory use of the server

The podman stats command shows various statistics about all containers running within the main workshop
container. For example, you should see something like:

	ID            NAME                    CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	d28f21e33505  liberty_beforeappstart  2.64%       99.48MB / 2.047GB  4.86%       0B / 0B     0B / 0B     65          821.827ms   6.30%

which shows the Liberty server you started in step 3 running with 99MB of memory or about the
same memory as without using InstantOn.

6. Hit control-C to stop the server.

7. Start and stop the server a few times to get a feeling for how the startup time and memory
consumption varies in different server instances.

Repeat steps 3 and 6 a few times, noting the elapsed startup time in each run and checking the
memory usage figure in the other terminal window you started in step 4.

You won't see exactly the same time and memory usage in different runs, but the server startup time
usually falls within a few tenths of a second and the memory usage is typically within a few MB.

You can also try runs with 2 cores to see what affect the additional CPU resources has.

	$ podman run \
	       --cpus=2 \
	       --network=host \
	       --cap-add=CHECKPOINT_RESTORE \
	       --cap-add=SETPCAP \
	       --name=liberty_beforeappstart \
	       --replace \
	       liberty_beforeappstart

This server starts in 0.425 seconds:
	The defaultServer server started in 0.425 seconds.

In terms of memory usage:
	ID            NAME                   CPU %   MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	a9882bbf3760  liberty_beforeappstart 4.42%   101.1MB / 2.047GB  4.94%       0B / 0B     0B / 0B     65          1.090813s   5.47%

So 2 cores helped to start the server a little bit faster but maybe used a little bit more memory.

We can even try 4 cores and get a little more improvement but the return on investment isn't very
high given we added 2 extra CPU cores:

	$ podman run \
	       --cpus=4 \
	       --network=host \
	       --cap-add=CHECKPOINT_RESTORE \
	       --cap-add=SETPCAP \
	       --name=liberty_beforeappstart \
	       --replace \
	       liberty_beforeappstart

Again, the extra 2 cores help the server to start a little bit faster:
	The defaultServer server started in 0.368 seconds.

	ID            NAME               CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
f3753b7e1277  liberty_beforeappstart     2.59%       97.94MB / 2.047GB  4.78%       0B / 0B     0B / 0B     68          1.132061s   5.52%	

Memory usage seems a bit lower but this is probably just run-to-run variation.

8. You're done! 

Let's update our performance table:
JDK			Cores		Start time	Memory usage
Temurin			1		5.524s		191MB
Semeru			1		2.971s		95MB
Semeru beforeAppStart	1		0.517		99MB

Temurin			2		2.531s		232MB
Semeru			2		1.933s		96MB
Semeru beforeAppStart	2		0.425		101MB

Temurin			4		1.913s		272MB
Semeru			4		1.718s		97MB
Semeru beforeAppStart	4		0.368		97MB

Using the beforeAppStart checkpoint and Liberty InstantOn, the server can start dramatically faster
and doesn't seem to use much more memory. On top of that, the running JVM is a full JVM with an
active JIT compiler that can adapt and start compiling for the workload as it arrives.

From the table, you can see that Semeru Runtimes manages to reach almost the same start-up performance
with half the CPU resources needed by the Temurin JDK. As more cores are made available to Temurin, the
server seems to be consistently using more memory after the server has started. With Semeru Runtimes,
however, this effect is much less pronounced and the overall memory usage is just a little over a
third of what's being used by Temurin.

Another way to express these results: a decision to use Temurin to start OpenLiberty results in
as much as 85% longer start times (1 core) and can use as much as 2.8 times as much memory (4 cores).
These differences can have a dramatic impact on responsiveness to changes in load as well as the
overall deployment costs, since more memory can translate to VM instances that cost more money.

This completes the third section in the workshop! In the next and final section, we'll see how these
startup times can be improved even more when the afterAppStart checkpoint is used.
