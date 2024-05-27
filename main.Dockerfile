FROM icr.io/appcafe/ibm-semeru-runtimes:open-17-jdk-ubi AS semeru

FROM docker.io/redhat/ubi9

RUN yum update -y \
 && yum install -y podman runc git procps net-tools maven vim man unzip \
 && yum -y clean all && rm -fr /var/cache

COPY --from=semeru /opt/java /opt/java

ADD Workshop_SharedCache /Workshop_SharedCache
ADD Workshop_InstantOn /Workshop_InstantOn
ADD Workshop_CloudCompiler /Workshop_CloudCompiler

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

