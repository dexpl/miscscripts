#!/bin/bash

mac=${1:-$(xclip -o)}
mac=${mac:-$(xclip -o -sel c)}
curl --location --silent http://api.macvendors.com/${mac}
