#!/bin/bash

docker run \
	--device=/dev/net/tun:/dev/net/tun \
	--device=/dev/kvm:/devb/kvm \
	--cap-add NET_ADMIN \
	--hostname buildserver \
	-it \
	-v /home/jptagaio/yocto/output/:/home/build/work \
	-v/home/jptagaio/yocto/output/sstate-cache:/home/build/sstate-cache \
	-v /home/jptagaio/yocto/output/download:/home/build/downloads \
	yoctocontainer:latest

# /dev/tun -> Access to the tunnel interface for docker. Access to the network via the docker bridge
# /dev/kvm -> If we want to use the kvm network interface for qemu images.
# --cap-add NET_ADMIN -> Adds linux capabilities to the container. In this case NET_ADMIN perform various network-related operations.
# --hostname -> Container hostname
# -i -> interactive - Keep STDIN open even if not attached.
# -t -> Allocate a pseudo TTY.
# -v -> -v|--volume[=[[HOST-DIR:]CONTAINER-DIR[:OPTIONS]]] -> Create a bind mount. HOST-DIR must be an absolute path or a name value.


