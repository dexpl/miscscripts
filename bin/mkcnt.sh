#!/bin/bash

# Container name; symlinks this script to mk<container> (e. g. mkcentos to run
# centos container)
cntname="$(basename ${0} .sh)"
cntname="${cntname#mk}"
# Docker image to build the container from
image="${1}"
shift
# Command to run inside the container
cmd="$@"
# Command to run upon container start
startcmd="sleep infinity"

ansible localhost -a "name=${cntname} image=${image} command='${startcmd}' auto_remove=yes" -m docker_container -o
[ -n "${cmd}" ] && ansible all -a "${cmd}" -c docker -i "${cntname},"
