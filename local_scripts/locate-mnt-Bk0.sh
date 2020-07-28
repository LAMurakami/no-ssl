#!/bin/sh
renice +19 -p $$ >/dev/null 2>&1
ionice -c2 -n7 -p $$ >/dev/null 2>&1
updatedb --require-visibility no \
--prunepaths /mnt/Bk0/lost+found \
--output /mnt/Bk0/mlocate.db \
--database-root /mnt/Bk0

# Script to rebuild the /mnt/Bk0 locate database for NFS client users

# To run this once
# sudo time -v /usr/local/scripts/locate-mnt-Bk0.sh

# To have the system run this daily
# sudo ln -s /usr/local/scripts/locate-mnt-Bk0.sh /etc/cron.daily/mlocate-mnt-Bk0
