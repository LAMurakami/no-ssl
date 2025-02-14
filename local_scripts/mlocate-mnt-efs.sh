#!/bin/sh
renice +19 -p $$ >/dev/null 2>&1
ionice -c2 -n7 -p $$ >/dev/null 2>&1
updatedb --require-visibility no \
--output /mnt/efs/mlocate.db \
--database-root /mnt/efs

chmod o+r /mnt/efs/mlocate.db

# Script to rebuild the /mnt/efs locate database for NFS client users

# To run this once
# sudo time -v /usr/local/scripts/locate-mnt-efs.sh

# To have the system run this daily
# sudo ln -s /usr/local/scripts/locate-mnt-efs.sh /etc/cron.daily/mlocate-mnt-efs
