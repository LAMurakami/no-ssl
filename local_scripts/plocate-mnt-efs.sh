#!/bin/sh
renice +19 -p $$ >/dev/null 2>&1
ionice -c2 -n7 -p $$ >/dev/null 2>&1
updatedb --require-visibility no \
--output /mnt/efs/plocate.db \
--database-root /mnt/efs

# Script to rebuild the /mnt/efs plocate database for NFS client users

# To run this once
# sudo time -v /var/www/no-ssl/local_scripts/plocate-mnt-efs.sh

# To have the system run this daily
# sudo ln -s /var/www/no-ssl/local_scripts/plocate-mnt-efs.sh \
# /etc/cron.daily/plocate-mnt-Bk0
