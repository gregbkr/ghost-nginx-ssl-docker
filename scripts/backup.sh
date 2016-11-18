#!/bin/bash
echo "#########################################################################"
echo "## BACKUP GHOST BLOG - `date +%A` - `date +%Y-%m-%d_%Hh%Mm%Ss` ##########"
echo "#########################################################################"

DAY=$(date +%A)
FULLDATE=$(date -I)

mkdir -p /root/backup/ghost
cd /root/blog

echo "1. Stop ghost"
docker stop blog_ghost_1

echo "2. Backup data folder"
tar -zcvf /root/backup/ghost/ghost-$FULLDATE.tar.gz -C /var/lib/docker/volumes/blog_ghost/_data/ .

echo "3. Start ghost"
docker start blog_ghost_1

echo "## END BACKUP GHOST BLOG - `date +%A` - `date +%Y-%m-%d_%Hh%Mm%Ss` ##########"

