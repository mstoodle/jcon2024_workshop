Welcome to a workshop aimed to help you learn about Semeru Runtimes
(https://www.infoq.com/news/2021/10/ibm-introduces-semeru-openj9/) and
WebSphere OpenLiberty (https://openliberty.io/) InstantOn technology
(https://openliberty.io/docs/latest/instanton.html) and how it can help
you run workloads that start in just a few hundred milliseconds without
any limitations on the Java programming langauge features you use.

This workshop is divided into 4 sections that each explore a different
experiment in starting the Getting Started application in the OpenLiberty
server.

Since Liberty is JDK and Java version agnostic, you can start Liberty with
any JDK. In the first section of this workshop, you'll start Liberty
using the Eclipse Temurin JDK even though Temurin is not the default
choice for Liberty. You'll be looking at the memory usage after startup
and the startup time for this configuration as you vary the number of
CPU cores made available to start the server.

In the second section, you'll go through the same process, but this time
you'll use the default JDK that Liberty containers use: the IBM Semeru
Runtimes JDK (https://www.infoq.com/news/2021/10/ibm-introduces-semeru-openj9/).
This JDK uses a prepopulated shared classes cache to start the container
in about half the time. You'll also see that the server consumes much less
(again, about half) the memory after starting.

In the third section, you will go see the steps required to take advantage
of the latest InstantOn technology that leverages Linux process checkpointing
to restore a previously initialized Liberty server in just a few hundred
milliseconds. As you'll learn, InstantOn offers two specific checkpoints
in the Liberty startup process: 1) beforeAppStart, and 2) afterAppStart.
You'll be measuring the memory use and server startup time for the
beforeAppStart checkpoint in this third section and you'll see dramatically
faster startup with similar memory use as seen in the second section.

Finally, in the fourth section of this workshop, you'll go through the
same steps as in the third section, but this time you'll use the
afterAppStart checkpoint. You'll see another significant improvement
in startup time and again the same memory use.

Because of the way checkpointing works, pretty much any application that
doesn't use native libraries will be able to use the beforeAppStart
checkpoint and achieve dramatically faster Liberty server startup times
suitable for completely elastic, even serverless level deployments. Some
applications may also be able to benefit from the afterAppStart or may
be able to use this checkpoint with some additional effort to properly
safeguard application data initialized before the checkpoint that may
need to be updated when the server is restored. We won't be able to get
into that process in this workshop.

Each section contains a README.md file that describe the steps to take in
that section, explains the commands you'll be using, and discusses the
results you'll measure.

We hope you enjoy going through this workshop!
