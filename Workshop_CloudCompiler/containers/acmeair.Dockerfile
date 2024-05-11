# Dockerfile used for creating a container capable to run AcmeAir monolithic
# Must be running on the same network as the mongodb container
# mongo.properties file must contain the machine where mongo is going to be run
FROM icr.io/appcafe/open-liberty:kernel-slim-java17-openj9-ubi


# The following line is needed if "jre" directory does not exist
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="/opt/java/openjdk/bin:${PATH}"

COPY --chown=1001:0 acmeair.LibertyFiles/server.xml /config/server.xml
COPY --chown=1001:0 acmeair.LibertyFiles/mongo.properties /config/mongo.properties
COPY --chown=1001:0 acmeair.LibertyFiles/acmeair-webapp-2.0.0-SNAPSHOT.war /config/apps
ENV ACMEAIR_PROPERTIES=/config/mongo.properties

EXPOSE 9090

USER 1001:0
#ENV VERBOSE=true
RUN features.sh
RUN configure.sh

RUN mkdir /tmp/vlogs
