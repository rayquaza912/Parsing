#!/bin/bash
# Dignostic for @Webserver
# Dependencies : bc, dnsutils, csv2html

ipv4='192.168.10.10'; dns1=ns1.carnofluxe.domain; dns2=ns2.carnofluxe.domain
output=diagnostic

function getResponseTime () {
	for i in `seq 1 3`; do
		eval seq_${i}=`ping -c 1 $1 | head -n 2 | tail -n 1 | cut -d ' ' -f 7 | grep -oE '[0-9]+\.[0-9]+'`
	done

	if [ -z $seq_1 ] || [ -z $seq_2 ] || [ -z $seq_3 ]; then
		echo 'Error'
	else
		r=$(echo "$seq_1+$seq_2+$seq_3" | bc )
		echo "$r ms"
	fi
}

function getResolvStat () {
	a=`nslookup $1 | grep -oE 'Address: ([0-9]{1,3}\.){3}[0-9]{1,3}' | sed 's/Address: //g'`
	#a=`nslookup $1 | grep -oE 'name = ([a-z0-9]|\-|\.)+' | sed 's/name = //g'`
	b=`nslookup $2 | grep -oE 'Address: ([0-9]{1,3}\.){3}[0-9]{1,3}' | sed 's/Address: //g'`

	if [ "$a" = "" ] || [ "$b" = "" ]; then
		echo 'Error, Error'
	else
		echo "${a},${b}"
	fi
}

function checkVirtualHosts () {
	list=""
	httpStatus=""

	for i in $@; do
		if wget --spider $i 2> /dev/null; then
			eval httpStatus="${httpStatus},UP"
		else
			eval httpStatus="${httpStatus},DOWN"
		fi
		eval list="${list},${i}"
	done

	echo $httpStatus
	if [ ! -f ${output}.csv ]; then
		echo "Timestamp,Average response time,DNS 1,DNS 2${list}" > ${output}.csv
	fi
}


tStamp=$(date +%x-%X)
rTime=`getResponseTime $ipv4`
rStatus=`getResolvStat $dns1 $dns2`
vHosts=`checkVirtualHosts carnofluxe.domain supervision.carnofluxe.domain wiki.carnofluxe.domain`

echo "${tStamp},${rTime},${rStatus}${vHosts}" >> ${output}.csv

/root/.local/bin/csv2html -o ${output}.html ${output}.csv
scp ${output}.html slave@${ipv4}:/var/www/supervision/
scp ${output}.csv slave@${ipv4}:/var/www/supervision/
