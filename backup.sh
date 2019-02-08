#!/bin/bash
# Apache2 Data backups

directories='/var/www/ /etc/apache2/ /var/log/apache2/'
destination='/mnt/raid1'
list='~/last_backup.list'
date=`date +%d-%m-%Y`

tar cvzf ${destination}/backup-${date}.tar.gz --listed-incremental=${list} $directories

