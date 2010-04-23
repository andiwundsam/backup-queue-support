#!/bin/bash
for i in coruscant yoda-new; do
    rsync -av --exclude .svn/ . --exclude deploy.sh root@$i:/usr/local/backup-queue/
done
