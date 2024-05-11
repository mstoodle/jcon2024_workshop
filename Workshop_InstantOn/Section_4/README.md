Section_4

In this section of the workshop, we'll be running the Liberty server using the Liberty/Semeru
InstantOn technology to save a checkpointed Liberty server using the afterAppStart checkpoint.
We'll find that the server starts again much faster even than the Liberty server using the
beforeAppStart checkpoint.

1. Build the getting started application

	$ mvn package

2. Build an OpenLiberty container that contains the getting started application. There is
a Dockerfile.liberty_afterappstart file provided that builds the container and also
starts the Liberty server before issuing the afterAppStart checkpoint.
Run the following command:

	$ podman --runtime runc build \
	    --network=host \
	    -f Dockerfile.liberty_afterappstart \
	    --no-cache \
	    -t liberty_afterappstart \
	    --cap-add=CHECKPOINT_RESTORE \
	    --cap-add=SYS_PTRACE \
	    --cap-add=SETPCAP \
	    --security-opt seccomp=unconfined \
	    .

3. Run the container. It will automatically start the OpenLiberty server by restoring the
saved checkpoint and then completing the server startup (i.e. loading applications).
Run the following command and wait for the server to start:

	$ podman --runtime runc run \
	       --cpus=1 \
	       --network=host \
	       --cap-add=CHECKPOINT_RESTORE \
	       --cap-add=SETPCAP \
	       --security-opt seccomp=unconfined \
	       --name=liberty_afterappstart \
	       --replace \
	       liberty_afterappstart

Look for the elapsed time to start the server. You'll see a line that ends with something like::
	The defaultServer server started in 0.253 seconds.

Without using a checkpoint, the Liberty start time with one core was 2.917 seconds.
The afterAppStart checkpoint enable Liberty to start in 8.7% of the time. Put another
way, if you don't use the afterAppStart checkpoint, the Liberty server will take
approximately 11.5X longer to start! If you use Temurin, it will take 21.8X longer to start!

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

	ID            NAME                    CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	978ce8a85204  liberty_afterappstart   2.64%       95.23MB / 2.047GB  4.65%       0B / 0B     0B / 0B     65          642.76ms    4.80%

which shows the Liberty server you started in step 3 running with 95MB of memory or about the
same memory as without using InstantOn.

You can leave this podman stats command running for step 7.

7. Hit control-C to stop the server.

8. Start and stop the server a few times to get a feeling for how the startup time and memory
consumption varies in different server instances.

Repeat steps 3 and 7 a few times, noting the elapsed startup time in each run and checking the
memory usage figure in the other terminal window you started in step 6.

You won't see exactly the same time and memory usage in different runs, but the server startup time
usually falls within a few tenths of a second and the memory usage is typically within a few MB.

You can also try runs with 2 cores to see what affect the additional CPU resources has.

	$ podman --runtime runc run \
	       --cpus=2 \
	       --network=host \
	       --cap-add=CHECKPOINT_RESTORE \
	       --cap-add=SETPCAP \
	       --security-opt seccomp=unconfined \
	       --name=liberty_afterappstart \
	       --replace \
	       liberty_afterappstart

This server starts a little bit faster in 0.228 seconds:
	The defaultServer server started in 0.228 seconds.

In terms of memory usage:
	ID            NAME                   CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	5b1d65a53571  liberty_afterappstart  3.70%       95.27MB / 2.047GB  4.65%       0B / 0B     0B / 0B     65          930.875ms   4.56%

So 2 cores helped to start the server a very little bit faster and didn't change the memory usage.

We can even try 4 cores and get a little more improvement but the return on investment isn't very
high given we added 2 extra CPU cores:

	$ podman --runtime runc run \
	       --cpus=4 \
	       --network=host \
	       --cap-add=CHECKPOINT_RESTORE \
	       --cap-add=SETPCAP \
	       --security-opt seccomp=unconfined \
	       --name=liberty_afterappstart \
	       --replace \
	       liberty_afterappstart

Again, the extra 2 cores didn't actually help because more cores means more resources to initialize,
although there could be some variation run-to-run at play here too:.
	The defaultServer server started in 0.250 seconds.

	ID            NAME                   CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
	594bd2491762  liberty_afterappstart  3.06%       94.91MB / 2.047GB  4.64%       0B / 0B     0B / 0B     68          690.365ms   5.25%

Memory usage is about the same at 95MB.

9. Optionally, stop the podman stats command running in the other terminal window by hiting
control-C. You can also leave this command running for the other sections of this workshop so
you can keep watching the statistics for the containers you use.

9. You're done! 

Let's update our performance table:
JDK			Cores		Start time	Memory usage
Temurin			1		5.524s		191MB
Semeru			1		2.971s		95MB
Semeru beforeAppStart	1		0.517		99MB
Semeru afterAppStart	1		0.253		95MB

Temurin			2		2.531s		232MB
Semeru			2		1.933s		96MB
Semeru beforeAppStart	2		0.425		101MB
Semeru afterAppStart	2		0.228		95MB

Temurin			4		1.913s		272MB
Semeru			4		1.718s		97MB
Semeru beforeAppStart	4		0.368		97MB
Semeru afterAppStart	4		0.250		95MB

Using the afterAppStart checkpoint and Liberty InstantOn, the server can start dramatically faster
and doesn't seem to use any more memory. On top of that, the running JVM is a full JVM with an
active JIT compiler that can adapt and start compiling for the workload as it arrives. The
"afterApStart" checkpoint completes more of the server startup activity before taking the
checkpoint, so it reduces the restore time by quite a bit. But this checkpoint can also require
some support from applications in case they initialize data in their loading code that needs
to be adapted after the checkpoint loads. That isn't the case in this simple "Getting Started"
application but it could very well happen in a more sophisticated application.

From the table, you can see that Semeru Runtimes far exceeds the startup performance offered by
Temurin when InstantOn is used by OpenLiberty. While there are other JDKs and technologies that
may be able to offer comparable or even better start-up for simple applications, Liberty and
Semeru InstantOn can be used even with complicated JakartaEE applications with the same
simplicity of adding one line to the Dockerfile to create a checkpoint and then the restored
checkpoint is running a full JVM, a full JIT compiler, and no impact to how you write your
Java code or which libraries you are allowed to use.

We hope you enjoyed this workshop and learned more about how startup time and memory usage
can be dramatically different depending on which JDK you use to deploy your Java workloads.
You have seen how a simple one line change to the Dockerfile to activate the InstantOn
checkpointing can dramatically reduce start time with little or no impact to memory usage.

Faster start time means you can provide a more responsive and elastic infrastucture without
managing "on deck" servers and without resorting to technologies like native image.
Lower memory usage can translate into smaller VMs which cost less money. It's that simple.

This completes the fourth and final section of this workshop! Great work!
