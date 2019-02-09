#!/bin/bash
# Apache2 Data backups

directories='/var/www/ /etc/apache2/ /var/log/apache2/'
destination='/mnt/raid1'
list='~/last_backup.list'
checkfile='~/backup_errors.tmp'; checksize=`cat $checkfile | wc -l`
date=`date +%d-%m-%Y`

mkdir ${destination}/${date}/
tar cvzf ${destination}/${date}/backup-${date}.tar.gz --listed-incremental=${list} $directories 2>  $checkfile
cp $list ${destination}/${date}/list-${date}.list
cp $checkfile ${destination}/${date}/errors-${date}.tmp

if [ `cat $checkfile | wc -l` -gt $checksize ]; then
	echo '============================'; echo -e "\033[33mWarning : \e[0m please see $checkfile for more details."
	from=`echo "$(cat $checkfile | wc -l) - $cheksize + 1" | bc`
	tail -n $from $chekfile
	echo '============================'
	# notify admin
fi

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

if [ `ls $destination | head | wc -l` -ge 180 ]; then
	checkDate
fi
