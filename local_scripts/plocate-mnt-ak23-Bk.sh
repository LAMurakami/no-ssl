#!/bin/sh
renice +19 -p $$ >/dev/null 2>&1
ionice -c2 -n7 -p $$ >/dev/null 2>&1
updatedb --require-visibility no \
--prunepaths /mnt/ak23-Bk/lost+found \
--output /mnt/ak23-Bk/plocate.db \
--database-root /mnt/ak23-Bk

chmod o+r /mnt/ak23-Bk/plocate.db

# Script to rebuild the /mnt/ak23-Bk plocate database for NFS client users

# To run this once
# sudo time -v /var/www/no-ssl/local_scripts/plocate-mnt-ak23-Bk.sh

