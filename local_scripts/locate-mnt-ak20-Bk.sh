#!/bin/sh
renice +19 -p $$ >/dev/null 2>&1
ionice -c2 -n7 -p $$ >/dev/null 2>&1
updatedb --require-visibility no \
--prunepaths "/mnt/ak20-Bk/lost+found /mnt/ak20-Bk/timeshift" \
--output /mnt/ak20-Bk/plocate.db \
--database-root /mnt/ak20-Bk

chmod a+r /mnt/ak20-Bk/plocate.db

# Script to rebuild the /mnt/ak20-Bk locate database for NFS client users

# To run this once
# sudo time -v /var/www/no-ssl/local_scripts/locate-mnt-ak20-Bk.sh
