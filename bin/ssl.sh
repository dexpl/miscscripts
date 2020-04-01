#!/bin/bash

server_name=${1:?No server name given}
server_port=${2:-443}
action=$(basename $0 .sh); action=${action##ssl}; [ -n "${action}" ] && action=-${action}
#< /dev/null openssl s_client -connect ${server_name}:${server_port} 2>/dev/null | openssl x509 -noout -${action}
< /dev/null openssl s_client -connect ${server_name}:${server_port} | openssl x509 -noout ${action}
