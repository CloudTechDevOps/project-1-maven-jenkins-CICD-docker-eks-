#--------------------with mavne and tomcat images---------
#FROM maven:3.8.4-eclipse-temurin-17 AS build
#RUN mkdir /app
#WORKDIR /app
#COPY . .
#RUN mvn package

#FROM tomcat:latest
#COPY --from=build /app/webapp/target/webapp.war /usr/local/tomcat/webapps/webapp.war
#RUN cp -R  /usr/local/tomcat/webapps.dist/*  /usr/local/tomcat/webapps


#------------------------with tomcat image mavne need to be install and run goal before-------------
# we need to install mavne and run goal make it ready war file 
# FROM tomcat:latest
# RUN cp -R  /usr/local/tomcat/webapps.dist/*  /usr/local/tomcat/webapps
# COPY /webapp/target/*.war /usr/local/tomcat/webapps


#--------------------taking maven on ubuntu and tomacate image ------------------
# FROM ubuntu:latest as builder
# RUN apt-get update && \
#     apt-get install -y openjdk-8-jdk wget unzip

# ARG MAVEN_VERSION=3.9.6
# RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz && \
#     tar -zxvf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
#     rm apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
#     mv apache-maven-${MAVEN_VERSION} /usr/lib/maven

# ENV MAVEN_HOME /usr/lib/maven
# ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
# ENV PATH=$MAVEN_HOME/bin:$PATH
# RUN mkdir -p /app
# COPY . /app
# WORKDIR /app
# RUN mvn install


# FROM tomcat:latest
# COPY --from=builder /app/webapp/target/webapp.war /usr/local/tomcat/webapps/webapp.war
# RUN cp -R  /usr/local/tomcat/webapps.dist/*  /usr/local/tomcat/webapps



#----------------maven and tomcate on ubuntu ------------------------

# Use the official Ubuntu image as the base image for building the Maven project
FROM ubuntu:20.04 AS build

# Set non-interactive mode for installing packages
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages: OpenJDK 17, Maven, and other utilities
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    maven \
    wget \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Set the working directory in the container
WORKDIR /app

# Copy the project files into the container
COPY . .

# Build the project using Maven
RUN mvn clean package

# Debug: List the contents of the target directory to confirm the WAR file
RUN ls -al /app/webapp/target
# Use the official Ubuntu image as the base for the runtime environment
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set the Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Download and extract Tomcat (correcting the download and extraction paths)
RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.95/bin/apache-tomcat-9.0.95.tar.gz -O /tmp/tomcat.tar.gz && \
    mkdir /opt/tomcat && \
    tar xzvf /tmp/tomcat.tar.gz -C /opt/tomcat --strip-components=1 && \
    rm /tmp/tomcat.tar.gz

# Set up Tomcat environment variables
ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

# Expose Tomcat port
EXPOSE 8080

# Copy the generated WAR file from the build stage
COPY --from=build /app/webapp/target/webapp.war /opt/tomcat/webapps/webapp.war
# Start Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]

