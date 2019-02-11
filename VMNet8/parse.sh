#!/bin/bash
# Apache2 log parser

if [ -z $1 ]; then log='/var/log/apache2/site-access.log'
else log=$1
fi

sep=','   
output=/var/www/supervision/site-access

if [ ! -f ${output}.csv ]; then
	echo 'Timestamp, Source IP' > ${output}.csv
fi

for i in `seq 1 $(cat $log | wc -l)`; do
	timestamp=`grep -oE '[0-9]{2}/[aAbcDeFgJlMnNoOprStuvy]{3}/2[0-9]{3}(:[0-9]{2}){3}' $log | head -n $i | tail -n 1`
	ipv4=`grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' $log | head -n $i | tail -n 1`
	echo "${timestamp},${ipv4}" >> ${output}.csv
done

/root/.local/bin/csv2html -o ${output}.html ${output}.csv
