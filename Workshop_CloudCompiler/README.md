In this workshop, we're going to look at using the Semeru Cloud Compiler
to offload JIT compilation resources from client JVMs so that the Java
application does not see the intensive memory and CPU demands with the
JIT compiler is actively compiling code.

To get started, though, we need to build some containers that we'll be
using in the various workshop sections. Go to the containers directory
and run the all.build.sh script:
	$ cd containers
	$ ./all.build.sh

This command builds all the various container images needed for this
workshop that fall into these four categories :
	1. Mongodb
	2. AcmeAir
	3. JMeter
	4. JIT Server

Once you've built the containers, you can go to the first section of
the workshop:
	$ cd ../Section_1

From there, follow the steps in the README.md. When you're done with
Section_1, continue on to Section_2 and its README.md!

Have fun!
