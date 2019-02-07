#!/bin/bash
# Apache log parser

if [ -z $1 ]; then log='/var/log/apache2/access.log'
else log=$1
fi

sep=','
output=clients

if [ ! -f $output ]; then
	echo 'Timestamp, Source IP' > ${output}.csv
fi

for i in `seq 1 $(cat $log | wc -l)`; do
	timestamp=`grep -oE '[0-9]{2}/[aAbcDeFgJlMnNoOprStuvy]{3}/2[0-9]{3}(:[0-9]{2}){3}' $log | head -n $i | tail -n 1`
	ipv4=`grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' $log | head -n $i | tail -n 1`
	#echo -n $timestamp; echo -n ${sep}; echo $ipv4 >> $output
	echo "${timestamp},${ipv4}" >> ${output}.csv
done

csv2html -o ${output}.html ${output}.csv
