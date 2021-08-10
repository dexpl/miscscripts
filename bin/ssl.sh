#!/bin/bash

# If two params are given, they must be host and port
# If one param is given and it's an existing file name, try reading it
# If one param is given and it contains ://, consider it being some SSL URL
# If one param is given, it contains : but no ://, consider it being host:port
# If one param is given, it neither is a file nor contains no : nor ://,
# consider it being HTTPS-accessible host name
# If no params are given, try reading a cert from stdin

set -e

action=$(basename $0 .sh)
action=${action##ssl}
[ -n "${action}" ] && action=-${action}
action="openssl x509 -noout ${action}"
if [ $# -eq 0 ]; then
	${action}
	exit $?
elif [ $# -eq 1 ]; then
	cert_name=${1}
	if [ -f "${cert_name}" ]; then
		${action} -in "${cert_name}"
		exit $?
	else
		if [[ "${1}" == *'://'* ]]; then
			IFS=/ read -r -a urlsplit <<< "${1%%\?*}"
			proto=${urlsplit[0]:0:-1}
			connect_to=${urlsplit[2]}
		else
			connect_to=${1}
		fi
	fi
elif [ $# -eq 2 ]; then
	connect_to=${1}:${2}
else
	echo "Incorrect command line arguments: '$@', giving up">&2
	exit 2
fi

if [ -n "${connect_to}" ]; then
	[[ "${connect_to}" == *':'* ]] || connect_to=${connect_to}:${proto:-443}
	< /dev/null openssl s_client -connect ${connect_to} | ${action}
else
	echo "Nothing to do; try running `bash -x $0 $@` to see what's wrong">&2
	exit 3
fi
