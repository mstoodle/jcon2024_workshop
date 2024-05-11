# Dockerfile to build a jmeter container able to drive acmeair
# Results appear on /output in the container
# Must specify the hostname for the acmeair application (or localhost will be assumed)

FROM docker.io/eclipse-temurin:17

ENV JMETER_VERSION 5.4.3 

# Install pre-requisite packages
RUN apt-get update && apt-get install -y --no-install-recommends wget unzip \
       && rm -rf /var/lib/apt/lists/*

# Install jmeter 
RUN mkdir /jmeter \
 && mkdir /output \
 && cd /jmeter/ \
 && wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz \
 && tar -xzf apache-jmeter-$JMETER_VERSION.tgz \ 
 && rm apache-jmeter-$JMETER_VERSION.tgz 

# Set jmeter home, add jmeter to the PATH and set JVM options
ENV JMETER_HOME="/jmeter/apache-jmeter-$JMETER_VERSION"

# Add jmeter to the PATH
ENV PATH="$JMETER_HOME/bin:$PATH"

# Set JVM options
ENV JVM_ARGS "-Xms1g -Xmx1g"

# We should set summariser.interval=6 in bin/jmeter.properties
RUN echo 'summariser.interval=6' >> $JMETER_HOME/bin/jmeter.properties

# Copy the script to be executed and other needed files
COPY jmeter/AcmeAir-v32.jmx $JMETER_HOME/AcmeAir-v3.jmx
COPY jmeter/Airports.csv $JMETER_HOME/Airports.csv
COPY jmeter/Airports2.csv $JMETER_HOME/Airports2.csv
COPY jmeter/hosts.csv $JMETER_HOME/hosts.csv
COPY jmeter/json-simple-1.1.1.jar $JMETER_HOME/lib/ext/
COPY jmeter/acmeair-driver-1.0-SNAPSHOT.jar $JMETER_HOME/lib/ext/
COPY jmeter/jmeter-plugin-influxdb2-listener-1.5-all.jar $JMETER_HOME/lib/ext/
COPY jmeter/applyLoad.sh $JMETER_HOME/bin/applyLoad.sh
RUN chmod u+x $JMETER_HOME/bin/applyLoad.sh

# Adjust the host this is going to connect to based on an environment variable
ENV LIBERTYHOST localhost

# Environment variables that we want the user to redefine
ENV JPORT=9090 \
    JUSERBOTTOM=0 \
    JUSER=199 \
    JURL=acmeair-webapp \
    JTHREAD=15 \
    JDURATION=60 \
    JRAMPUP=0 \
    JTHINKTIME=0 \
    JINFLUXDBBUCKET=jmeter

ENTRYPOINT ["applyLoad.sh"]
#jmeter -n -DusePureIDs=true -t AcmeAir-v3.jmx -j /tmp/acmeair.stats.0 -JPORT=9090 -JUSER=99 -JURL=acmeair-webapp -JTHREAD=15 -JDURATION=600


