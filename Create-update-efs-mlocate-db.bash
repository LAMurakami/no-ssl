#!/usr/bin/bash

for EFS in efs efs2 efs3 ; do
    if [ -d /mnt/${EFS} ] ; then
        echo "/mnt/${EFS} directory exists."
        if [ ! -f /mnt/${EFS}/mlocate.db ] ; then
            echo "/mnt/${EFS}/mlocate.db does not exist"
            echo "Create /mnt/${EFS}/mlocate.db"
            /var/www/no-ssl/local_scripts/mlocate-mnt-${EFS}.sh # Build
            chmod o+r /mnt/${EFS}/mlocate.db # Allow all to read
        else
            one_day_ago=$(date -d 'now - 1 day' +%s)
            file_time=$(date -r "/mnt/${EFS}/mlocate.db" +%s)
            if (( $file_time <= $one_day_ago )); then
                echo "/mnt/${EFS}/mlocate.db is older than 1 day"
                echo "update /mnt/${EFS}/mlocate.db"
                /var/www/no-ssl/local_scripts/mlocate-mnt-${EFS}.sh # Update
                chmod o+r /mnt/${EFS}/mlocate.db # Allow all to read
            fi
        fi
    else
        echo "/mnt/${EFS} directory does not exist."
    fi
done

SYSTEM_LOCATE_PATH='/mnt/efs/mlocate.db:/mnt/efs2/mlocate.db'
if [ ! -f /mnt/efs3/mlocate.db ] ; then
    SYSTEM_LOCATE_PATH="${SYSTEM_LOCATE_PATH}:/mnt/efs3/mlocate.db"
fi
echo "export LOCATE_PATH=${SYSTEM_LOCATE_PATH}" > /etc/profile.d/mlocate.sh
