#!/bin/sh
renice +19 -p $$ >/dev/null 2>&1
ionice -c2 -n7 -p $$ >/dev/null 2>&1
updatedb --require-visibility no \
--output /mnt/efs2/plocate.db \
--database-root /mnt/efs2

chmod o+r /mnt/efs2/plocate.db

# Script to rebuild the /mnt/efs2 plocate database for NFS client users

# To run this once
# sudo time -v /var/www/no-ssl/local_scripts/plocate-mnt-efs2.sh

# To have the system run this daily
# sudo ln -s /var/www/no-ssl/local_scripts/plocate-mnt-efs2.sh \
# /etc/cron.daily/plocate-mnt-efs2.sh
