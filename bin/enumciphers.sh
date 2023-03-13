#!/bin/bash
#
# Enum TLS ciphers supported by given host:port
#
# Usage: enumciphers.sh host:port [openssl options]

hostport=${1:?Usage: $(basename ${0}) host:port [openssl options]}
shift
opensslopts=${*}

for cipher in $(openssl ciphers 'ALL:eNULL' | tr ':' ' ')
do
	openssl s_client -cipher "$cipher" -connect ${hostport} ${opensslopts} < /dev/null 2>/dev/null | awk '/Cipher/ && $NF != "0000" && $NF !~ /NONE/ { print($NF) }'
done | sort -u
