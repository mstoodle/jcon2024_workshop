This repo contains the materials first prepared for JCON Europe 2024.

The workshop abstract is:
Java with Ultra Fast Startup and Remote JIT Compilation

Java starting too slowly for you? Amazed that your program has to JIT compile
the same old methods every time you run it, consuming memory and CPU cycles
that you’ve got to pay for? It doesn’t have to be that way! With Eclipse OpenJ9
built into the Semeru Runtimes JDK, you can start your Linux-based Java servers
and then save them to disk. When you need another instance, don’t start it from
scratch! Simply restore it from disk to avoid almost all that startup work to get
your server handling requests in just a couple hundred milliseconds! And that
powerful JIT compiler can be easily configured to run as a remote service so that
your applications aren’t disrupted by those extra CPU cycles and memory use. In
this workshop, we’ll teach you a bit more about these amazing technologies and
then let you try them out yourselves with some simple Liberty-based servers running
on the OpenShift Container Platform. You’ll see firsthand why these technologies
are being used in production today to provide incredibly elastic and cost-effective
servers for Java workloads. You know you’re curious! Bring your questions and an
open mind and let us show you how you too can overcome Java’s traditional overheads
without restricting the use of any Java language features!


Unfortunately, due to a scheduling mishap, OpenShift Container Platform resources
were not available for the workshop, so we're going to run the experiments
locally on people's machines. To hopefully simplify that process, we're going to
use containers to control the environment.

In particular, we will run the entire workshop out of one redhat/ubi9 container
that preinstalls the required software for the workshops. Then, there are three
segments (WorkshopSharedCache, WorkshopInstantOn, and WorkshopCloudCompiler)
that take attendees through a sequence of experiments that showcase how these
technologies can be used to accelerate startup and reduce memory usage.

Although not recommended as common practice, this workshop needs to run as
root so that its containers within containers can work without issues. If
you are not running as the root user on your system, you'll want to switch
to it before proceeding with the workshop:
	sudo /bin/bash
Please be careful in the rest of this workshop because you will be running
as root with super powers.

To create the main workshop container, you will need to build the main container
using the following command:

$ podman build --network=host -f main.Dockerfile -t workshop/main .

It may take a while to build on your computer, but once this container is built
you should have everything you need to go through the workshop.

Start the container and do all your work inside that container:

$ podman run --network=host --privileged --name=workshop/main --replace -it workshop/main /bin/bash

Once you have the container up and running, the usual progression is to start with
$ cd /Workshop_SharedCache
$ cat README.md
$ cd Section_1
$ cat README.md
...
$ cd ../Section_2
$ cat README.md
...

When done with the SharedCache workshop, you can cd back up to the root to move to
the InstantOn workshop:
$ cd /Workshop_InstantOn/Section_1
$ cat README.md
...

When you finish the InstantOn workshop, you can cd back up to the root to move to
the CloudCompiler workshop:
$ cd /Workshop_CloudCompiler/Section_1
$ cat README.md
...

That's it! Good luck!

When you're done, if you logged in as root you'll want to logout before you move on
to other things! Or just close the terminal window you've been working in.


NOTE: all the documentation for this workshop assumes you are using "podman" to
run your containers. If you use docker, just replace "podman" with "docker" and
the commands should otherwise work.

If you need help installing podman onto your computer, here are a couple of reference
links to help:

MacOS:
Just follow the installation instructions here:
https://www.redhat.com/sysadmin/run-containers-mac-podman

If you're down in the details, the workshop works best if the podman machine has at
least 4 cores and 4GB of memory. If you don't know how that matters, don't worry about
it but some of the workshop exercises that run with 2 or 4 cores may not show the
results described in the README.mds.

Make sure you initialize and start the podman machine before trying to run the above
command to start the workshop/main container.

Windows:
First install the Windows Subsystem for Linux (WSL):
https://learn.microsoft.com/en-us/windows/wsl/install

When you get to the "Change the default Linux distribution installed" section on that page,
I suggest you choose either a UBI9 or a very recent Ubuntu (22.04 or later).

Linux
There is probably a "podman" package available via your standard package manager (yum, apt, etc.)
Google "install podman <package manager name>" or your distribution name and you should find
useful links to get podman installed.
