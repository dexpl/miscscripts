#!/bin/bash

# If two params are given, they must be host and port
# If one param is given and it's an existing file name, try reading it
# If one param is given and it contains ://, consider it being some SSL URL
# If one param is given, it contains : but no ://, consider it being host:port
# If one param is given, it neither is a file nor contains no : nor ://,
# consider it being HTTPS-accessible host name
# If no params are given, try reading a cert from stdin

punycode() {
	[ "$(type -p idn)" ] && idn "${1}" || echo "${1}"
}

# split host:port on host and port
# assign'em to hostsplit array
splithost() {
	IFS=: read -r -a hostsplit <<< "${1}"
}

# connect to given host:port
connect() {
	set -e
	< /dev/null ${openssl} s_client -connect ${1} | ${action}
}

openssl=${OPENSSL_BIN:-openssl}
action=$(basename $0 .sh)
action=${action##ssl}
[ -n "${action}" ] && action="-${action} -nameopt utf8"
action="${openssl} x509 -noout ${action}"
if [ $# -eq 0 ]; then
	${action}
	exit $?
elif [ $# -eq 1 ]; then
	cert_name=${1}
	if [ -e "${cert_name}" ]; then
    if [ "$(env LC_MESSAGES=C file -b "${cert_name}")" == 'PEM certificate' ]; then
      ${action} -in "${cert_name}"
    else
      ${action} -in ${cert_name} -inform DER
    fi
		exit $?
	else
		if [[ "${1}" == *'://'* ]]; then
			IFS=/ read -r -a urlsplit <<< "${1%%\?*}"
			proto=${urlsplit[0]:0:-1}
			splithost ${urlsplit[2]}
		else
			splithost ${1}
		fi
		connect $(punycode ${hostsplit[0]}):${hostsplit[1]:-${proto:-443}}
	fi
elif [ $# -eq 2 ]; then
	connect $(punycode ${1}):${2}
else
	echo "Incorrect command line arguments: '$@', giving up">&2
	exit 2
fi
