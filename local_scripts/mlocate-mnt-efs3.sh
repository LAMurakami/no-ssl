#!/bin/sh
renice +19 -p $$ >/dev/null 2>&1
ionice -c2 -n7 -p $$ >/dev/null 2>&1
updatedb --require-visibility no \
--output /mnt/efs3/mlocate.db \
--database-root /mnt/efs3

chmod o+r /mnt/efs3/mlocate.db

# Script to rebuild the /mnt/efs3 locate database for NFS client users

# To run this once
# sudo time -v /var/www/no-ssl/local_scripts/mlocate-mnt-efs3.sh
