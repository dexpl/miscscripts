#!/bin/bash

for acro in "$@"
do
	xmlstarlet sel --net -t -m /acronym/found -i '@n > 0' -o "${acro^^} is" -n -b -m acro -o '	' -v expan -i 'string-length(comment)' -o ' /* ' -v comment -o ' */' -b -n http://acronyms.silmaril.ie/cgi-bin/xaa?${acro}
done
