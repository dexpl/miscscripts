#!/bin/bash

server_name=${1:?No server name given}
server_port=${2:-443}
action=$(basename $0 .sh); action=${action##ssl}
echo | openssl s_client -connect ${server_name}:${server_port} 2>/dev/null | openssl x509 -noout -${action:-text}
