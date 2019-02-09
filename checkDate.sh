#!/bin/bash

currentTime=`date +%s`

for i in `ls`; do
	creationTime=`date -d $(stat -c %y $i | cut -d ' ' -f 1) +%s`
	gapTime=`echo "$currentTime - $creationTime" | bc`

	if [ $gapTime -ge 15814800 ]; then
		echo "Vous pouvez supprimer $i"
	fi
done

