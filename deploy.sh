#!/bin/bash
rsync -av --exclude .svn/ . --exclude deploy.sh root@yoda-new:/usr/local/backup-queue/
