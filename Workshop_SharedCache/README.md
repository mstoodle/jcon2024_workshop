Welcome to a workshop aimed to help you learn about Semeru Runtimes
(https://www.infoq.com/news/2021/10/ibm-introduces-semeru-openj9/)  shared classes
cache technology (https://eclipse.dev/openj9/docs/shrc/) and how using Semeru
Runtimes can help you run workloads that start much faster (in about half the
time) and consume less memory (again, about half).

This workshop is divided into 5 sections that each explore a different topic.

The first two sections look at using the OpenLiberty web server with Semeru
Runtimes to see the impact of using shared class cache or not.

The following three sections switch gears to look at the Apache Tomcat v10
server to measure the startup and memory use for both the Eclipse Temurin JDK
(https://adoptium.net/temurin/) which is the JDK used in the official Tomcat
containers (`https://hub.docker.com/_/tomcat`) as well as the IBM Semeru
Runtimes JDK.

Each section contains a README.md file that describe the steps to take in
that section, explains the commands you'll be using, and discusses the
results you'll measure.

These instruction all assume you are using 'podman', but if you're using
Docker just replace every use of 'podman' with 'docker' and everything
should otherwise just work.

We hope you enjoy going through this workshop!
