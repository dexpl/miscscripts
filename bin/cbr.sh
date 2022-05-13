#!/bin/sh

[ -n "${1}" ] && date_req="?date_req=$(date --date "${*}" +%d/%m/%Y)"
xmlstarlet sel --net -t -v //ValCurs/@Date -n -m '//CharCode[text() = "USD" or text() = "EUR" or text() = "CNY" or text() = "INR"]' -v 'concat(../Nominal, " ", ../Name, ": ", translate(../Value, ",", "."))' -n http://www.cbr.ru/scripts/XML_daily.asp${date_req} | dos2unix | column -ts ':'
