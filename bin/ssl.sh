#!/bin/bash

# If two params are given, they must be host and port
# If one param is given and it's an existing file name, try reading it
# If one param is given and it contains ://, consider it being some SSL URL
# If one param is given, it contains : but no ://, consider it being host:port
# If one param is given, it neither is a file nor contains no : nor ://,
# consider it being HTTPS-accessible host name
# If no params are given, try reading a cert from stdin

set -e

punycode() {
	[ "$(type -p idn)" ] && idn "${1}" || echo "${1}"
}

service2port() {
	if [[ "${1}" =~ ^[[:digit:]][[:digit:]]+$ ]]; then
		echo ${1}
	else
		read -r -a service < <(getent services "${1}")
		echo ${service[-1]%%/*}
	fi
}

# split host:port on host and port
# assign'em to hostsplit array
splithost() {
	IFS=: read -r -a hostsplit <<< "${1}"
}

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
			splithost ${urlsplit[2]}
		else
			splithost ${1}
		fi
		connect_to=$(punycode ${hostsplit[0]}):$(service2port ${hostsplit[1]:-${proto:-443}})
	fi
elif [ $# -eq 2 ]; then
	connect_to=$(punycode ${1}):$(service2port ${2})
else
	echo "Incorrect command line arguments: '$@', giving up">&2
	exit 2
fi

if [ -n "${connect_to}" ]; then
	< /dev/null openssl s_client -connect ${connect_to} | ${action}
else
	echo "Nothing to do; try running `bash -x $0 $@` to see what's wrong">&2
	exit 3
fi
