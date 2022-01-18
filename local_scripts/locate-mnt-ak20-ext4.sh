#!/bin/sh
renice +19 -p $$ >/dev/null 2>&1
ionice -c2 -n7 -p $$ >/dev/null 2>&1
updatedb --require-visibility no \
--prunepaths /mnt/ak20-ext4/lost+found \
--output /mnt/ak20-ext4/mlocate.db \
--database-root /mnt/ak20-ext4

# Script to rebuild the /mnt/ak20-ext4 locate database for NFS client users

# To run this once
# sudo time -v /var/www/no-ssl/local_scripts/locate-mnt-ak20-ext4.sh

# To have the system run this daily
# sudo ln -s /var/www/no-ssl/local_scripts/locate-mnt-ak20-ext4.sh \
# /etc/cron.daily/mlocate-mnt-ak20-ext4
