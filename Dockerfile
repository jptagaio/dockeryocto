#This docker file is based on: https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/2823422188/Building+Yocto+Images+using+a+Docker+Container

#In order to run this Dockerfile use the following command:
# -> docker build -t yoctocontainer .
# 		-> t -> --tag list -> Name and optionally a tag in the name:tag
# 		-> . -> The current directory. Run this command in the directory where Dockerfile is


# Use Ubuntu 22.04
FROM ubuntu:22.04

# Defines build variables. In this case is the DEBIAN_FRONTEND variable.
ARG DEBIAN_FRONTEND=noninteractive

# Install packages that are required to build the yocto image.
RUN \
        dpkg --add-architecture i386 && \
        apt-get update && \
        apt-get install -yq sudo build-essential git nano vim\
          python3 python3-pip python3-pexpect python3-jinja2 python3-subunit python3-yaml \
			 python3-git libncursesw5 libncursesw5:i386 \
          man bash diffstat gawk chrpath wget cpio \
          texinfo lzop apt-utils bc screen libncurses5-dev locales xz-utils\
          libc6-dev-i386 doxygen libssl-dev dos2unix xvfb x11-utils gcc \
          g++-multilib libssl-dev:i386 zlib1g-dev:i386 debianutils \
          libtool libtool-bin procps python3-distutils pigz socat \
          zstd iproute2 lz4 iputils-ping liblz4-tool file libacl1 \
          curl libtinfo5 net-tools xterm rsync u-boot-tools unzip zip && \

        rm -rf /var/lib/apt-lists/* && \
        echo "dash dash/sh boolean false" | debconf-set-selections && \
        dpkg-reconfigure dash

#Fetch repo from google
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo && chmod a+x /bin/repo

#Replace python in /bin/repo with python3. Not required anymore
#RUN sed -i "1s/python/python3/" /bin/repo

#Added build user to group 1000 -> This UID and GID should be equal to the host machine in order to use the shared folder.
RUN groupadd build -g 1000
# Useradd -> Adds a user. 
# -m -> Creates a home folder if it does not exist. 
# -s -> The name of the user#'s login shell. In this case is /bin/bash. 
# -p -> Defines the password.
# -u -> Defines the UID (user id).
# -g -> Defines the GID (group id).
# The usermod command is adding the build user to the sudo group
RUN useradd -ms /bin/bash -p build build -u 1000 -g 1000 && \
        usermod -aG sudo build && \
        echo "build:build" | chpasswd

#Defines the locales to be generated and generates the locales
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

#Defines the environmental variable LANG to en_US.utf8
ENV LANG en_US.utf8

#Sets the user and group ID
USER build
#Change working directory
WORKDIR /home/build

# Define the variable BB_ENV_PASSTHROUGH_ADDITIONS. This variable does the following:
# Specifies an additional set of variables to allow through from the external environment into BitBake’s datastore.
# This list of variables are on top of the internal list set in BB_ENV_PASSTHROUGH
# In this case we are adding the DL_DIR and SSTATE_DIR variables.
# DL_DIR -> The central download directory used by the build process to store downloads.
# SSTATE_DIR -> The directory for the shared state cache.
# Finally and in order to use git we define a email and user for git.
RUN echo "export BB_ENV_PASSTHROUGH_ADDITIONS=\"DL_DIR SSTATE_DIR\"" >> ~/.bashrc
RUN echo "export DL_DIR=\"${HOME}/sstate-cache\"" >> ~/.bashrc
RUN echo "export SSTATE_DIR=\"${HOME}/downloads\"" >> ~/.bashrc
RUN git config --global user.email "build@example.com" && git config --global user.name "Build"
