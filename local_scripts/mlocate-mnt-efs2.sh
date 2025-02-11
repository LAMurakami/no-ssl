#!/bin/sh
renice +19 -p $$ >/dev/null 2>&1
ionice -c2 -n7 -p $$ >/dev/null 2>&1
updatedb --require-visibility no \
--output /mnt/efs2/mlocate.db \
--database-root /mnt/efs2

# Script to rebuild the /mnt/efs2 locate database for NFS client users

# To run this once
# sudo time -v /var/www/no-ssl/local_scripts/mlocate-mnt-efs2.sh
