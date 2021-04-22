#!/bin/bash

# Exclusively for https://voronezh.hh.ru/vacancy/40955682

# Copy given source file to given targets, either local or remote.
# Actual copying is done using rsync(1).
# Usage: mcsi.sh [-n] [-z] /path/to/source /local/target remote:/target
# mcsi.sh /etc/passwd /srv/backup/ 10.0.0.1:/srv/backup 10.2.3.4:/tmp/
# will (try to) copy /etc/passwd to /srv/backup/ directory both locally and on
# 10.0.0.1 and to /tmp/ on 10.2.3.4. Options -n and -z, if given, are passed to
# rsync as is.

# NB: if you really need to use sshpass(1) and clear-text passwords, use
# env RSYNC_RSH="sshpass -p YOURPASS ssh" mcsi.sh /path/to/source /local/target remote:/target

# TODO arbitrary rsync(1) option support
while getopts ":nz" Option
do
	case ${Option} in
		n|z)
		rsync_opts="${rsync_opts} -${Option}"
		;;
	esac
done

shift $((${OPTIND} - 1))
# TODO support whitespaces in paths
src=${1}
shift
cnt=0
for dest in ${*}
do
	# TODO somewhat improve error accumulation algorythm
	rsync ${rsync_opts} ${src} ${dest} || ERROR=$((10 * cnt++ + $? + ERROR))
	shift
done
exit ${ERROR}
