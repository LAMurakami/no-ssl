#!/bin/bash

<<PROGRAM_TEXT

This script will rebuild an archive of /var/www/no-ssl resources
 if any of the resources have been changed or added.

The archive is extracted on a new instance with:

tar -xvzf /mnt/efs/aws-lam1-ubuntu/no-ssl.tgz --directory /var/www

The following will list files changed since the archive was last rebuilt:

if [ $(find /var/www/no-ssl -newer /mnt/efs/aws-lam1-ubuntu/no-ssl.tgz -print \
 | sed 's|^/var/www/no-ssl/||' | grep -v '.git/' | grep -v '.git$' | wc -l) \
 -gt 0 ]
then
  find /var/www/no-ssl -newer /mnt/efs/aws-lam1-ubuntu/no-ssl.tgz \
  | grep -v '.git/' | grep -v '.git$' \
  | xargs ls -ld --time-style=long-iso  | sed 's|/var/www/no-ssl/||' 
fi

PROGRAM_TEXT

if [ $(find /var/www/no-ssl -newer /mnt/efs/aws-lam1-ubuntu/no-ssl.tgz -print \
| sed 's|^/var/www/no-ssl/||' | grep -v '.git/' \
| grep -v '.git$' | wc -l) -gt 0 ]; then

  echo Recreating the aws-lam1-ubuntu/no-ssl.tgz archive

  rm -f /mnt/efs/aws-lam1-ubuntu/no-ssl.t{gz,xt}

  tar -cvzf /mnt/efs/aws-lam1-ubuntu/no-ssl.tgz \
  --exclude='no-ssl/.git' \
  --exclude='no-ssl/html/RCS' \
  --directory /var/www no-ssl 2>&1 \
  | tee /mnt/efs/aws-lam1-ubuntu/no-ssl.txt

fi
