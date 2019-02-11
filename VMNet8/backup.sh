#!/bin/bash
# Apache2 Data backups

directories='/var/www/ /etc/apache2/ /var/log/apache2/'
destination='/mnt/raid5'
list='last_backup.list'
checkfile='backup_errors.tmp'; checksize=`cat $checkfile | wc -l`
date=`date +%d-%m-%Y_%H_%M`

function makeBackup () {

	mkdir ${destination}/${date}/

	if [ ! "$1" = "inc" ]; then
		rm $list 2> /dev/null
	fi

	tar cvzf ${destination}/${date}/backup-${date}.tar.gz --listed-incremental=${list} $directories 2>> $checkfile
	cp $list ${destination}/${date}/list-${date}.list
	cp $checkfile ${destination}/${date}/errors-${date}.tmp 2> /dev/null	
	warnAlert

}

function warnAlert() {

if [ `cat $checkfile | wc -l` -gt $checksize ]; then
	echo '============================'; echo -e "\033[33mWarning : \e[0m please see $checkfile for more details."
	from=`cat $checkfile | wc -l`
	from=$(($from - $checksize))
	tail -n $from $checkfile | tee ${destination}/${date}/current_errrors.txt 
	echo '============================'
	# notify admin
fi

}

function checkDate () {

currentTime=`date +%s`
toDelete=''
for i in `ls`; do
	creationTime=`date -d $(stat -c %y $i | cut -d ' ' -f 1) +%s`
	gapTime=`echo "$currentTime - $creationTime" | bc`

	if [ $gapTime -ge 15814800 ]; then
	echo '============================'; echo -e "\033[33mWarning : \e[0m some files no longer requiered :"
	eval toDelete="$toDelete, $i"
	fi
done
echo $toDelete
echo '============================'

}

makeBackup $1

if [ `ls $destination | head | wc -l` -ge 180 ]; then
	checkDate
fi
